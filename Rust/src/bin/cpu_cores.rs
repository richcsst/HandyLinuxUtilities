use std::env;
use std::fs::File;
use std::io::{self, BufRead};

fn get_os_name() -> String {
    if let Ok(file) = File::open("/etc/os-release") {
        let reader = io::BufReader::new(file);
        for line in reader.lines().map_while(Result::ok) {
            if line.starts_with("PRETTY_NAME=") {
                let mut val = line["PRETTY_NAME=".len()..].to_string();
                // Strip structural quotes
                if val.starts_with('"') { val.remove(0); }
                if val.ends_with('"') { val.pop(); }
                return val;
            }
        }
    }
    "Linux".to_string()
}

fn get_cpu_model() -> String {
    if let Ok(file) = File::open("/proc/cpuinfo") {
        let reader = io::BufReader::new(file);
        for line in reader.lines().map_while(Result::ok) {
            if line.starts_with("model name") {
                if let Some(colon_idx) = line.find(':') {
                    return line[colon_idx + 1..].trim().to_string();
                }
            }
        }
    }
    "Generic CPU".to_string()
}

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() > 1 {
        if let Ok(httpd) = env::var("SERVER_SOFTWARE") {
            println!("HTTP Server is {}", httpd);
        }
        println!("\n OS:  {}", get_os_name());
        println!("CPU:  {}\n", get_cpu_model());
    } else {
        // Query cores directly from standard system config thread manager
        let num_cpus = num_cpus::get();
        println!("{}", num_cpus);
    }
}

