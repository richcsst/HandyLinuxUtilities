#include <iostream>
#include <string>
#include <algorithm>
#include <cctype>
#include <cstdlib>
#include <curl/curl.h>
#include <nlohmann/json.hpp> // Header-only JSON library

using json = nlohmann::json;
extern char **environ;

// Callback for libcurl to write incoming data straight into a C++ string
static size_t WriteCallback(void *contents, size_t size, size_t nmemb, std::string *userp) {
    size_t total_size = size * nmemb;
    userp->append((char*)contents, total_size);
    return total_size;
}

std::string fetch_url(CURL *curl_handle, const std::string &url) {
    std::string response_string;
    curl_easy_setopt(curl_handle, CURLOPT_URL, url.c_str());
    curl_easy_setopt(curl_handle, CURLOPT_WRITEFUNCTION, WriteCallback);
    curl_easy_setopt(curl_handle, CURLOPT_WRITEDATA, &response_string);
    curl_easy_setopt(curl_handle, CURLOPT_USERAGENT, "libcurl-agent/1.0");

    CURLcode res = curl_easy_perform(curl_handle);
    if (res != CURLE_OK) {
        std::cerr << url << " not responding as expected: " << curl_easy_strerror(res) << "\n";
        return "";
    }
    return response_string;
}

int main(int argc, char *argv[]) {
    // 1. Check environment
    for (char **env = environ; *env != nullptr; env++) {
        if (std::string(*env).rfind("WHATISMYIP_", 0) == 0) {
            std::cerr << "WHATISMYIP variables already exist. Skipping API call.\n";
            return 1;
        }
    }

    if (argc < 2) {
        std::cerr << "Missing key\n";
        return 1;
    }
    std::string key = argv[1];

    curl_global_init(CURL_GLOBAL_ALL);
    CURL *curl_handle = curl_easy_init();
    if (!curl_handle) return 1;

    // 2. First API Call: Get IP
    std::string wimip_url = "https://wimi-api.whatismyip.com/ip?key=" + key;
    std::string json_ip_str = fetch_url(curl_handle, wimip_url);
    if (json_ip_str.empty()) {
        curl_easy_cleanup(curl_handle);
        return 1;
    }

    auto ip_json = json::parse(json_ip_str);
    std::string ip_str = ip_json["ip"];

    // 3. Second API Call: Get Meta Info
    std::string wimip_info_url = "https://wimi-api.whatismyip.com/ip-address-lookup/" + ip_str + "?key=" + key;
    std::string meta_str = fetch_url(curl_handle, wimip_info_url);
    
    curl_easy_cleanup(curl_handle);
    curl_global_cleanup();

    if (meta_str.empty()) return 1;

    // 4. Output loop with standard uppercase conversion strings
    auto info_json = json::parse(meta_str);
    for (auto& [name, val] : info_json.items()) {
        std::string upper_name = name;
        std::transform(upper_name.begin(), upper_name.end(), upper_name.begin(), [](unsigned char c){ return std::toupper(c); });
        std::cout << "export WHATISMYIP_" << upper_name << "=\"" << val.get<std::string>() << "\"\n";
    }

    return 0;
}

