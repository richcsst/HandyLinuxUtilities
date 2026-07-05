#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <curl/curl.h>
#include <json-c/json.h>

extern char **environ;

// Memory struct to handle libcurl responses dynamically
struct MemoryStruct {
    char *memory;
    size_t size;
};

// Callback function for libcurl to write incoming data
static size_t WriteMemoryCallback(void *contents, size_t size, size_t nmemb, void *userp) {
    size_t realsize = size * nmemb;
    struct MemoryStruct *mem = (struct MemoryStruct *)userp;

    char *ptr = realloc(mem->memory, mem->size + realsize + 1);
    if (!ptr) {
        fprintf(stderr, "not enough memory (realloc returned NULL)\n");
        return 0;
    }

    mem->memory = ptr;
    memcpy(&(mem->memory[mem->size]), contents, realsize);
    mem->size += realsize;
    mem->memory[mem->size] = 0;

    return realsize;
}

// Helper function to fetch URL content via libcurl
char* fetch_url(CURL *curl_handle, const char *url) {
    CURLcode res;
    struct MemoryStruct chunk;
    chunk.memory = malloc(1); 
    chunk.size = 0;    

    curl_easy_setopt(curl_handle, CURLOPT_URL, url);
    curl_easy_setopt(curl_handle, CURLOPT_WRITEFUNCTION, WriteMemoryCallback);
    curl_easy_setopt(curl_handle, CURLOPT_WRITEDATA, (void *)&chunk);
    curl_easy_setopt(curl_handle, CURLOPT_USERAGENT, "libcurl-agent/1.0");

    res = curl_easy_perform(curl_handle);

    if (res != CURLE_OK) {
        fprintf(stderr, "%s not responding as expected: %s\n", url, curl_easy_strerror(res));
        free(chunk.memory);
        return NULL;
    }

    return chunk.memory;
}

// Helper function to uppercase a string inline
void uppercase_string(char *str) {
    for (int i = 0; str[i]; i++) {
        str[i] = toupper((unsigned char)str[i]);
    }
}

int main(int argc, char *argv[]) {
    // 1. Check if any environment variables starting with WHATISMYIP_ already exist
    for (char **env = environ; *env != NULL; env++) {
        if (strncmp(*env, "WHATISMYIP_", 11) == 0) {
            fprintf(stderr, "WHATISMYIP variables already exist. Skipping API call.\n");
            return 1;
        }
    }

    // 2. Validate arguments (wimip [key])
    if (argc < 2) {
        fprintf(stderr, "Missing key\n");
        return 1;
    }
    const char *key = argv[1];

    // Initialize curl globally
    curl_global_init(CURL_GLOBAL_ALL);
    CURL *curl_handle = curl_easy_init();

    if (!curl_handle) {
        fprintf(stderr, "Failed to initialize curl\n");
        return 1;
    }

    // 3. First API Call: Get IP address
    char wimip_url[512];
    snprintf(wimip_url, sizeof(wimip_url), "https://wimi-api.whatismyip.com/ip?key=%s", key);
    
    char *json_ip = fetch_url(curl_handle, wimip_url);
    if (!json_ip) {
        curl_easy_cleanup(curl_handle);
        return 1;
    }

    // Parse the first JSON response
    struct json_object *parsed_ip_json = json_tokener_parse(json_ip);
    struct json_object *ip_obj;
    if (!parsed_ip_json || !json_object_object_get_ex(parsed_ip_json, "ip", &ip_obj)) {
        fprintf(stderr, "Failed to parse IP from response\n");
        free(json_ip);
        curl_easy_cleanup(curl_handle);
        return 1;
    }
    const char *ip_str = json_object_get_string(ip_obj);

    // 4. Second API Call: Get IP Info using the extracted IP
    char wimip_info_url[512];
    snprintf(wimip_info_url, sizeof(wimip_info_url), "https://wimi-api.whatismyip.com/ip-address-lookup/%s?key=%s", ip_str, key);

    char *meta = fetch_url(curl_handle, wimip_info_url);
    
    // Free the first response data since we are done with it
    json_object_put(parsed_ip_json);
    free(json_ip);

    if (!meta) {
        curl_easy_cleanup(curl_handle);
        return 1;
    }

    // Parse the second JSON response
    struct json_object *parsed_info_json = json_tokener_parse(meta);
    if (!parsed_info_json) {
        fprintf(stderr, "Failed to parse IP info response\n");
        free(meta);
        curl_easy_cleanup(curl_handle);
        return 1;
    }

    // 5. Iterate through JSON keys and print export statements
    json_object_object_foreach(parsed_info_json, key_name, val) {
        // Copy the key name to upper-case it
        char upper_key[256];
        strncpy(upper_key, key_name, sizeof(upper_key) - 1);
        upper_key[sizeof(upper_key) - 1] = '\0';
        uppercase_string(upper_key);

        const char *val_str = json_object_get_string(val);
        printf("export WHATISMYIP_%s=\"%s\"\n", upper_key, val_str);
    }

    // Cleanup
    json_object_put(parsed_info_json);
    free(meta);
    curl_easy_cleanup(curl_handle);
    curl_global_cleanup();

    return 0;
}

