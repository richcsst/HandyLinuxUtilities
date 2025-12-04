/*
 * showenv.c
 *
 * A C port of showenv.pl (prints environment variables with colors and some
 * special-highlight rules).
 *
 * Compile: gcc -std=c11 -Wall -Wextra -O2 -o showenv showenv.c
 *
 * Notes:
 *  - Uses extern char **environ (POSIX).
 *  - Uses ANSI escape sequences for colors.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>   /* for strncasecmp */
#include <ctype.h>
#include <errno.h>

extern char **environ;

/* ANSI color helpers (simple) */
#define ANSI_RESET "\033[0m"
#define ANSI_BOLD  "\033[1m"

const char *col_bright_white    = "\033[97m";
const char *col_on_blue         = "\033[44m";
const char *col_bold_white      = "\033[1;37m";
const char *col_bold_cyan       = "\033[1;36m";
const char *col_bright_green    = "\033[92m";
const char *col_green           = "\033[32m";
const char *col_bold_red        = "\033[1;31m";
const char *col_bold_brightblue = "\033[1;94m";
const char *col_bright_yellow   = "\033[93m";
const char *col_bright_red      = "\033[91m";
const char *col_bright_cyan     = "\033[96m";

/* print colored text and reset */
static void pcolor(const char *color, const char *s) {
    if (color) fputs(color, stdout);
    fputs(s ? s : "", stdout);
    fputs(ANSI_RESET, stdout);
}

/* Case-insensitive substring search fallback (returns pointer into haystack) */
static char *my_strcasestr(const char *haystack, const char *needle) {
    if (!*needle) return (char *)haystack;
    size_t nlen = strlen(needle);
    for (; *haystack; ++haystack) {
        if (tolower((unsigned char)*haystack) == tolower((unsigned char)*needle)) {
            if (strncasecmp(haystack, needle, nlen) == 0) return (char *)haystack;
        }
    }
    return NULL;
}

/* detect IPv4 in a string (simple, returns 1 and copies found IP into buf) */
static int has_ipv4(const char *s, char *buf, size_t bufsz) {
    const char *q = s;
    while (*q) {
        if (isdigit((unsigned char)*q)) {
            const char *r = q;
            int dots = 0;
            while (*r && (isdigit((unsigned char)*r) || *r == '.')) {
                if (*r == '.') dots++;
                r++;
            }
            if (dots == 3) {
                size_t len = r - q;
                if (len < bufsz) {
                    /* copy candidate and validate octets */
                    char tmp[128];
                    if (len >= sizeof(tmp)) { q = r; continue; }
                    memcpy(tmp, q, len);
                    tmp[len] = '\0';
                    char *tok = strtok(tmp, ".");
                    int ok = 1;
                    int count = 0;
                    while (tok) {
                        count++;
                        int val = atoi(tok);
                        if (val < 0 || val > 255) { ok = 0; break; }
                        tok = strtok(NULL, ".");
                    }
                    if (ok && count == 4) {
                        if (buf) {
                            memcpy(buf, q, len);
                            buf[len] = '\0';
                        }
                        return 1;
                    }
                }
            }
            q = r;
        } else q++;
    }
    return 0;
}

/* print value with highlighted special substrings */
static void print_colored_value(const char *envname, const char *val) {
    const char *s = val;
    /* Quick path: check for rarity of matches */
    if (!my_strcasestr(s, "truecolor") && !my_strcasestr(s, "256color") &&
        !my_strcasestr(s, "ubuntu") && !my_strcasestr(s, "redhat") &&
        !my_strcasestr(s, "fedora") && !my_strcasestr(s, "mint") &&
        !my_strcasestr(s, "zorin") && !my_strcasestr(s, "wayland")) {
        char ipbuf[64];
        if (has_ipv4(s, ipbuf, sizeof(ipbuf))) {
            const char *pos = strstr(s, ipbuf);
            if (!pos) { fputs(s, stdout); return; }
            size_t before = pos - s;
            if (before) fwrite(s, 1, before, stdout);
            pcolor(col_bright_green, ipbuf);
            fputs(pos + strlen(ipbuf), stdout);
            return;
        }
        fputs(s, stdout);
        return;
    }

    const char *cur = s;
    while (*cur) {
        const char *found = NULL;
        int kind = 0; /* 1=IP,2=truecolor,3=256color,4=ubuntu,5=redhat,6=fedora,7=mint,8=zorin,9=wayland */
        char matchbuf[128] = {0};

        char ipbuf[64];
        if (has_ipv4(cur, ipbuf, sizeof(ipbuf))) {
            char *pos = strstr(cur, ipbuf);
            if (pos) {
                found = pos; kind = 1; strncpy(matchbuf, ipbuf, sizeof(matchbuf)-1);
            }
        }

        const char *k;
        k = my_strcasestr(cur, "truecolor");
        if (k && (!found || k < found)) { found = k; kind = 2; strncpy(matchbuf, "truecolor", sizeof(matchbuf)-1); }
        k = my_strcasestr(cur, "256color");
        if (k && (!found || k < found)) { found = k; kind = 3; strncpy(matchbuf, "256color", sizeof(matchbuf)-1); }
        k = my_strcasestr(cur, "ubuntu");
        if (k && (!found || k < found)) { found = k; kind = 4; strncpy(matchbuf, "ubuntu", sizeof(matchbuf)-1); }
        k = my_strcasestr(cur, "redhat");
        if (k && (!found || k < found)) { found = k; kind = 5; strncpy(matchbuf, "redhat", sizeof(matchbuf)-1); }
        k = my_strcasestr(cur, "fedora");
        if (k && (!found || k < found)) { found = k; kind = 6; strncpy(matchbuf, "fedora", sizeof(matchbuf)-1); }
        k = my_strcasestr(cur, "mint");
        if (k && (!found || k < found)) { found = k; kind = 7; strncpy(matchbuf, "mint", sizeof(matchbuf)-1); }
        k = my_strcasestr(cur, "zorin");
        if (k && (!found || k < found)) { found = k; kind = 8; strncpy(matchbuf, "zorin", sizeof(matchbuf)-1); }
        k = my_strcasestr(cur, "wayland");
        if (k && (!found || k < found)) { found = k; kind = 9; strncpy(matchbuf, "wayland", sizeof(matchbuf)-1); }

        if (!found) { fputs(cur, stdout); break; }

        size_t prefix_len = found - cur;
        if (prefix_len) fwrite(cur, 1, prefix_len, stdout);

        switch (kind) {
            case 1: pcolor(col_bright_green, matchbuf); break;
            case 2:
                pcolor("\033[31m", "t"); pcolor("\033[32m", "r"); pcolor("\033[33m", "u"); pcolor("\033[36m", "e");
                pcolor("\033[94m", "c"); pcolor("\033[35m", "o"); pcolor("\033[92m", "l"); pcolor("\033[96m", "o"); pcolor("\033[32m", "r");
                break;
            case 3:
                pcolor("\033[31m", "2"); pcolor("\033[32m", "5"); pcolor("\033[33m", "6");
                pcolor("\033[36m", "c"); pcolor("\033[94m", "o"); pcolor("\033[35m", "l"); pcolor("\033[92m", "o"); pcolor("\033[96m", "r");
                break;
            case 4: pcolor("\033[38;5;202m", matchbuf); break;
            case 5: pcolor(col_bright_red, matchbuf); break;
            case 6: pcolor(col_bright_cyan, matchbuf); break;
            case 7: pcolor(col_bright_green, matchbuf); break;
            case 8: pcolor(col_bold_white, matchbuf); break;
            case 9: pcolor(col_bright_yellow, matchbuf); break;
            default: fwrite(matchbuf, 1, strlen(matchbuf), stdout);
        }

        cur = found + strlen(matchbuf);
    }
}

/* Print multi-line env value with special formatting similar to Perl script */
static void print_multiline(const char *name, const char *value, int maxlen) {
    char hdrfmt[64];
    snprintf(hdrfmt, sizeof(hdrfmt), "%%%ds = ---", maxlen);
    char hdr[512];
    snprintf(hdr, sizeof(hdr), hdrfmt, name);

    pcolor(col_bright_white, hdr);
    fputc('\n', stdout);

    int indent = maxlen + 4;
    const char *p = value;
    while (*p) {
        const char *eol = strchr(p, '\n');
        size_t linelen = eol ? (size_t)(eol - p) : strlen(p);
        char *line = (char *)malloc(linelen + 1);
        if (!line) { perror("malloc"); exit(2); }
        memcpy(line, p, linelen);
        line[linelen] = '\0';

        char *colon = strchr(line, ':');
        if (colon) {
            size_t fsz = colon - line;
            char *f = (char *)malloc(fsz + 1);
            if (!f) { perror("malloc"); exit(2); }
            memcpy(f, line, fsz); f[fsz] = '\0';
            const char *l = colon + 1;
            while (*l && isspace((unsigned char)*l)) l++;

            for (char *t = f; *t; ++t) *t = toupper((unsigned char)*t);

            /* Print field padded to 11 chars to approximate Perl behavior */
            char field_padded[32] = {0};
            snprintf(field_padded, sizeof(field_padded), "%s", f);
            int le = 11 - (int)strlen(field_padded);
            if (le < 0) le = 0;

            printf("%*s", indent, field_padded); /* right-justify inside indent */
            for (int i = 0; i < le; ++i) putchar(' ');
            fputs(" = ", stdout);

            if (strcmp(f, "IP") == 0) {
                pcolor(col_bright_green, l);
                fputc('\n', stdout);
            } else if (strcmp(f, "ISP") == 0) {
                pcolor(col_bold_white, l);
                fputc('\n', stdout);
            } else if (strncasecmp(l, "ok", 2) == 0) {
                pcolor(col_green, l);
                fputc('\n', stdout);
            } else if (strncasecmp(l, "us", 2) == 0) {
                pcolor(col_bold_red, "U"); pcolor(col_bold_white, "S"); pcolor(col_bold_brightblue, "A");
                fputc('\n', stdout);
            } else {
                print_colored_value(field_padded, l);
                fputc('\n', stdout);
            }

            free(f);
        } else {
            printf("%*s\n", indent, line);
        }

        free(line);
        if (!eol) break;
        p = eol + 1;
    }
}

/* Compare by variable name (up to '=' char) */
static int cmpstr(const void *a, const void *b) {
    const char *sa = *(const char * const *)a;
    const char *sb = *(const char * const *)b;
    const char *ea = strchr(sa, '=');
    const char *eb = strchr(sb, '=');
    size_t la = ea ? (size_t)(ea - sa) : strlen(sa);
    size_t lb = eb ? (size_t)(eb - sb) : strlen(sb);
    size_t lmin = la < lb ? la : lb;
    int r = strncmp(sa, sb, lmin);
    if (r != 0) return r;
    if (la < lb) return -1;
    if (la > lb) return 1;
    return 0;
}

int main(void) {
    size_t env_count = 0;
    for (char **e = environ; *e; ++e) env_count++;

    char **pairs = (char **)malloc(env_count * sizeof(char *));
    if (!pairs) { perror("malloc"); return 2; }

    size_t idx = 0;
    size_t maxname = 0;
    for (char **e = environ; *e; ++e) {
        char *eq = strchr(*e, '=');
        if (!eq) continue;
        size_t namelen = eq - *e;
        if (namelen > maxname) maxname = namelen;
        pairs[idx++] = *e;
    }
    env_count = idx;

    qsort(pairs, env_count, sizeof(char *), cmpstr);

    puts("");
    fputs(col_bright_white, stdout);
    fputs(col_on_blue, stdout);
    fputs("  Environment Variables", stdout);
    fputs(ANSI_RESET, stdout);
    fputc('\n', stdout);

    for (size_t i = 0; i < env_count; ++i) {
        char *eq = strchr(pairs[i], '=');
        if (!eq) continue;
        size_t namelen = eq - pairs[i];
        char name[namelen + 1];
        memcpy(name, pairs[i], namelen);
        name[namelen] = '\0';
        const char *value = eq + 1;

        if (strchr(value, '\n')) {
            print_multiline(name, value, (int)maxname);
        } else {
            char fmt[32];
            snprintf(fmt, sizeof(fmt), "%%%zus", maxname);
            fputs(col_bold_white, stdout);
            printf(fmt, name);
            fputs(ANSI_RESET, stdout);
            fputs(" = ", stdout);
            print_colored_value(name, value);
            fputc('\n', stdout);
        }
    }

    /* trailing blue line */
    fputs("\033[44m", stdout);
    fputs("\033[2K", stdout);
    fputs(ANSI_RESET, stdout);
    fputc('\n', stdout);

    free(pairs);
    return 0;
}

