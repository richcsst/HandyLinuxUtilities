#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <ctype.h>

extern char **environ;

// Struct to hold environment variable components
typedef struct {
    char *key;
    char *value;
} EnvVar;

// Comparison function for qsort
int compare_env(const void *a, const void *b) {
    return strcmp(((EnvVar *)a)->key, ((EnvVar *)b)->key);
}

// Case-insensitive string search helper
char *strcasestr_custom(const char *haystack, const char *needle) {
    if (!*needle) return (char *)haystack;
    for (; *haystack; haystack++) {
        if (tolower((unsigned char)*haystack) == tolower((unsigned char)*needle)) {
            const char *h, *n;
            for (h = haystack, n = needle; *h && *n; h++, n++) {
                if (tolower((unsigned char)*h) != tolower((unsigned char)*n)) break;
            }
            if (!*n) return (char *)haystack;
        }
    }
    return NULL;
}

// Simple IP regex detector: checks for 4 sets of 1-3 digits separated by dots
int contains_ip(const char *str) {
    int octets = 0, digits = 0;
    while (*str) {
        if (isdigit((unsigned char)*str)) {
            digits++;
            if (digits > 3) return 0;
        } else if (*str == '.') {
            if (digits == 0) return 0;
            digits = 0;
            octets++;
            if (octets > 3) return 0;
        } else {
            if (octets == 3 && digits > 0) return 1;
            octets = 0; digits = 0;
        }
        str++;
    }
    return (octets == 3 && digits > 0);
}

// Replaces targets with ansi-colored equivalents
void colorize_values(const char *val) {
    // Exact match cases (case-insensitive)
    if (strcasecmp(val, "true") == 0) {
        printf("\e[32m%s\e[0m", val); // green
        return;
    }
    if (strcasecmp(val, "stderr") == 0) {
        printf("\e[31m%s\e[0m", val); // red
        return;
    }

    // IP address fallback check
    if (contains_ip(val)) {
        printf("\e[92m%s\e[0m", val); // bright green
        return;
    }

    // Keyword string replacement simulation
    // Because C string building is manual, we'll scan for exact substring matches
    if (strcasestr_custom(val, "truecolor")) {
        printf("\e[31mt\e[32mr\e[33mu\e[36me\e[94mc\e[35mo\e[92ml\e[94mo\e[36mr\e[0m");
    } else if (strcasestr_custom(val, "256color")) {
        printf("\e[31m2\e[32m5\e[33m6\e[36mc\e[94mo\e[35ml\e[92ml\e[94mo\e[36mr\e[0m");
    } else if (strcasestr_custom(val, "ubuntu")) {
        printf("\e[38;5;202m%s\e[0m", val); // Extended ANSI 202 (Orange)
    } else if (strcasestr_custom(val, "redhat")) {
        printf("\e[91m%s\e[0m", val);
    } else if (strcasestr_custom(val, "fedora")) {
        printf("\e[96m%s\e[0m", val);
    } else if (strcasestr_custom(val, "mint")) {
        printf("\e[92m%s\e[0m", val);
    } else if (strcasestr_custom(val, "zorin")) {
        printf("\e[97m%s\e[0m", val);
    } else if (strcasestr_custom(val, "wayland")) {
        printf("\e[93m%s\e[0m", val);
    } else {
        printf("%s", val); // Defaults to normal printing if no matches
    }
}

int main() {
    // Get terminal size (Term::ReadKey equivalent)
    struct winsize w;
    ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
    // w.ws_col contains width, w.ws_row contains height

    int count = 0;
    int max_len = 0;

    // Count variables first
    for (char **env = environ; *env != NULL; env++) count++;

    EnvVar *env_list = malloc(count * sizeof(EnvVar));
    
    // Split environment strings into key/value pairs and track max key length
    int idx = 0;
    for (char **env = environ; *env != NULL; env++) {
        char *dup = strdup(*env);
        char *eq = strchr(dup, '=');
        if (eq) {
            *eq = '\0';
            env_list[idx].key = dup;
            env_list[idx].value = eq + 1;
            
            int len = strlen(env_list[idx].key);
            if (len > max_len) {
                max_len = len;
            }
            idx++;
        }
    }

    // Sort the list keys alphabetically
    qsort(env_list, idx, sizeof(EnvVar), compare_env);

    // Print Header
    // \e[2K clears the line. \e[93;44m is bright yellow text on blue background
    printf("\n\e[2K\e[93;44m  Environment Variables\e[0m\n");

    // Print body
    for (int i = 0; i < idx; i++) {
        // \e[1m = Bold. \e[33;41m = Yellow on Red background
        printf("\e[1m\e[33;41m %*s \e[0m = ", max_len, env_list[i].key);
        colorize_values(env_list[i].value);
        printf("\n");
    }

    // Print Footer
    printf("\e[44m\e[2K\e[0m\n");

    // Cleanup
    for (int i = 0; i < idx; i++) {
        free(env_list[i].key); // frees the duplicated str pointer
    }
    free(env_list);

    return 0;
}

