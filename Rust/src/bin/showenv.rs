use std::env;
use std::io::{self, Write};

fn contains_keyword(data: &str, keyword: &str) -> bool {
    data.to_lowercase().contains(&keyword.to_lowercase())
}

fn is_ip(s: &str) -> bool {
    let mut octets = 0;
    let mut digits = 0;
    for c in s.chars() {
        if c.is_ascii_digit() {
            digits += 1;
            if digits > 3 { return false; }
        } else if c == '.' {
            if digits == 0 { return false; }
            digits = 0;
            octets += 1;
            if octets > 3 { return false; }
        } else {
            return false;
        }
    }
    octets == 3 && digits > 0
}

fn colorize_values(val: &str) {
    if contains_keyword(val, "true") && val.len() == 4 { print!("\x1b[32m{}\x1b[0m", val); return; }
    if contains_keyword(val, "stderr") && val.len() == 6 { print!("\x1b[31m{}\x1b[0m", val); return; }
    if is_ip(val) { print!("\x1b[92m{}\x1b[0m", val); return; }

    if contains_keyword(val, "truecolor") {
        print!("\x1b[31mt\x1b[32mr\x1b[33mu\x1b[36me\x1b[94mc\x1b[35mo\x1b[92ml\x1b[94mo\x1b[36mr\x1b[0m");
    } else if contains_keyword(val, "256color") {
        print!("\x1b[31m2\x1b[32m5\x1b[33m6\x1b[36mc\x1b[94mo\x1b[35ml\x1b[92ml\x1b[94mo\x1b[36mr\x1b[0m");
    } else if contains_keyword(val, "ubuntu") {
        print!("\x1b[38;5;202m{}\x1b[0m", val);
    } else if contains_keyword(val, "redhat")  { print!("\x1b[91m{}\x1b[0m", val); }
      else if contains_keyword(val, "fedora")  { print!("\x1b[96m{}\x1b[0m", val); }
      else if contains_keyword(val, "mint")    { print!("\x1b[92m{}\x1b[0m", val); }
      else if contains_keyword(val, "zorin")   { print!("\x1b[97m{}\x1b[0m", val); }
      else if contains_keyword(val, "wayland") { print!("\x1b[93m{}\x1b[0m", val); }
      else { print!("{}", val); }
}

fn main() {
    let mut env_list: Vec<(String, String)> = env::vars().collect();
    
    // Sort environment variables alphabetically by key
    env_list.sort_by(|a, b| a.0.cmp(&b.0));

    let max_len = env_list.iter().map(|(k, _)| k.len()).max().unwrap_or(0);

    println!("\n\x1b[2K\x1b[93;44m  Environment Variables\x1b[0m");
    for (key, value) in env_list {
        print!("\x1b[1m\x1b[33;41m {:>width$} \x1b[0m = ", key, width = max_len);
        colorize_values(&value);
        println!();
        let _ = io::stdout().flush(); // Ensure line renders immediately
    }
    println!("\x1b[44m\x1b[2K\x1b[0m\n");
}

