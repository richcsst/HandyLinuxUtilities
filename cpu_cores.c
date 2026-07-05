#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

// Helper to extract a value from a file with a key=value setup like /etc/os-release
void get_os_name(char *buffer, size_t max_len) {
    FILE *fp = fopen("/etc/os-release", "r");
    if (!fp) {
        strncpy(buffer, "Unknown Linux", max_len);
        return;
    }

    char line[256];
    while (fgets(line, sizeof(line), fp)) {
        if (strncmp(line, "PRETTY_NAME=", 12) == 0) {
            char *start = line + 12;
            // Strip wrapping quotes if they exist
            if (*start == '"') start++;
            
            char *end = start + strlen(start) - 1;
            while (end > start && (*end == '\n' || *end == '"' || *end == '\r')) {
                *end = '\0';
                end--;
            }
            strncpy(buffer, start, max_len - 1);
            buffer[max_len - 1] = '\0';
            fclose(fp);
            return;
        }
    }
    fclose(fp);
    strncpy(buffer, "Linux", max_len);
}

// Helper to extract the CPU model name from /proc/cpuinfo
void get_cpu_model(char *buffer, size_t max_len) {
    FILE *fp = fopen("/proc/cpuinfo", "r");
    if (!fp) {
        strncpy(buffer, "Unknown Processor", max_len);
        return;
    }

    char line[256];
    while (fgets(line, sizeof(line), fp)) {
        if (strncmp(line, "model name", 10) == 0) {
            char *colon = strchr(line, ':');
            if (colon) {
                char *start = colon + 1;
                while (*start == ' ' || *start == '\t') start++; // Strip spaces
                
                char *end = start + strlen(start) - 1;
                while (end > start && (*end == '\n' || *end == '\r')) {
                    *end = '\0';
                    end--;
                }
                strncpy(buffer, start, max_len - 1);
                buffer[max_len - 1] = '\0';
                fclose(fp);
                return;
            }
        }
    }
    fclose(fp);
    strncpy(buffer, "Generic CPU", max_len);
}

int main(int argc, char *argv[]) {
    (void)argv;
    // If an argument is provided (equivalent to if (defined($ARGV[0])))
    if (argc > 1) {
        // Check if running within a web server context (Sys::Info's httpd method fallback)
        char *httpd = getenv("SERVER_SOFTWARE");
        if (httpd) {
            printf("HTTP Server is %s\n", httpd);
        }

        char os_name[128];
        char cpu_model[128];

        get_os_name(os_name, sizeof(os_name));
        get_cpu_model(cpu_model, sizeof(cpu_model));

        printf("\n OS:  %s\n", os_name);
        printf("CPU:  %s\n\n", cpu_model);
    } else {
        // No arguments: print active CPU core count
        long num_cpus = sysconf(_SC_NPROCESSORS_ONLN);
        printf("%ld\n", num_cpus);
    }

    return 0;
}

