#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
#include <iomanip>
#include <cctype>
#include <sys/ioctl.h>
#include <unistd.h>

extern char **environ;

struct EnvVar {
    std::string key;
    std::string value;
};

// Case-insensitive substring finder helper
bool contains_keyword(std::string data, std::string to_find) {
    std::transform(data.begin(), data.end(), data.begin(), [](unsigned char c) { return std::tolower(c); });
    std::transform(to_find.begin(), to_find.end(), to_find.begin(), [](unsigned char c) { return std::tolower(c); });
    return data.find(to_find) != std::string::npos;
}

bool is_ip(const std::string &s) {
    int octets = 0, digits = 0;
    for (char c : s) {
        if (std::isdigit(c)) {
            if (++digits > 3) return false;
        } else if (c == '.') {
            if (digits == 0 || ++octets > 3) return false;
            digits = 0;
        } else {
            return false;
        }
    }
    return (octets == 3 && digits > 0);
}

void colorize_values(const std::string &val) {
    if (contains_keyword(val, "true") && val.length() == 4) { std::cout << "\e[32m" << val << "\e[0m"; return; }
    if (contains_keyword(val, "stderr") && val.length() == 6) { std::cout << "\e[31m" << val << "\e[0m"; return; }
    if (is_ip(val)) { std::cout << "\e[92m" << val << "\e[0m"; return; }

    if (contains_keyword(val, "truecolor")) {
        std::cout << "\e[31mt\e[32mr\e[33mu\e[36me\e[94mc\e[35mo\e[92ml\e[94mo\e[36mr\e[0m";
    } else if (contains_keyword(val, "256color")) {
        std::cout << "\e[31m2\e[32m5\e[33m6\e[36mc\e[94mo\e[35ml\e[92ml\e[94mo\e[36mr\e[0m";
    } else if (contains_keyword(val, "ubuntu")) {
        std::cout << "\e[38;5;202m" << val << "\e[0m";
    } else if (contains_keyword(val, "redhat"))  { std::cout << "\e[91m" << val << "\e[0m"; }
      else if (contains_keyword(val, "fedora"))  { std::cout << "\e[96m" << val << "\e[0m"; }
      else if (contains_keyword(val, "mint"))    { std::cout << "\e[92m" << val << "\e[0m"; }
      else if (contains_keyword(val, "zorin"))   { std::cout << "\e[97m" << val << "\e[0m"; }
      else if (contains_keyword(val, "wayland")) { std::cout << "\e[93m" << val << "\e[0m"; }
      else { std::cout << val; }
}

int main() {
    std::vector<EnvVar> env_list;
    size_t max_len = 0;

    for (char **env = environ; *env != nullptr; env++) {
        std::string raw(*env);
        size_t eq_pos = raw.find('=');
        if (eq_pos != std::string::npos) {
            std::string key = raw.substr(0, eq_pos);
            std::string value = raw.substr(eq_pos + 1);
            max_len = std::max(max_len, key.length());
            env_list.push_back({key, value});
        }
    }

    std::sort(env_list.begin(), env_list.end(), [](const EnvVar &a, const EnvVar &b) {
        return a.key < b.key;
    });

    std::cout << "\n\e[2K\e[93;44m  Environment Variables\e[0m\n";
    for (const auto &ev : env_list) {
        std::cout << "\e[1m\e[33;41m " << std::setw(max_len) << ev.key << " \e[0m = ";
        colorize_values(ev.value);
        std::cout << "\n";
    }
    std::cout << "\e[44m\e[2K\e[0m\n";
    return 0;
}

