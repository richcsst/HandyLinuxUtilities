#include <iostream>
#include <fstream>
#include <string>
#include <cstdlib>
#include <unistd.h>

std::string get_os_name() {
    std::ifstream file("/etc/os-release");
    std::string line;
    if (file.is_open()) {
        while (std::getline(file, line)) {
            if (line.rfind("PRETTY_NAME=", 0) == 0) {
                std::string val = line.substr(12);
                if (!val.empty() && val.front() == '"') val.erase(0, 1);
                if (!val.empty() && val.back() == '"') val.pop_back();
                return val;
            }
        }
    }
    return "Linux";
}

std::string get_cpu_model() {
    std::ifstream file("/proc/cpuinfo");
    std::string line;
    if (file.is_open()) {
        while (std::getline(file, line)) {
            if (line.rfind("model name", 0) == 0) {
                size_t colon = line.find(':');
                if (colon != std::string::npos) {
                    std::string model = line.substr(colon + 1);
                    // Trim leading spaces
                    size_t start = model.find_first_not_of(" \t");
                    if (start != std::string::npos) model = model.substr(start);
                    return model;
                }
            }
        }
    }
    return "Generic CPU";
}

int main(int argc, [[maybe_unused]] char *argv[]) {
    if (argc > 1) {
        if (const char* httpd = std::getenv("SERVER_SOFTWARE")) {
            std::cout << "HTTP Server is " << httpd << "\n";
        }
        std::cout << "\n OS:  " << get_os_name() << "\n";
        std::cout << "CPU:  " << get_cpu_model() << "\n\n";
    } else {
        long num_cpus = sysconf(_SC_NPROCESSORS_ONLN);
        std::cout << num_cpus << "\n";
    }
    return 0;
}

