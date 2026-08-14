use serde::Deserialize;
use std::env;
use std::process;

#[derive(Deserialize)]
struct IpResponse {
    ip: String,
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // 1. Check if any environment variables starting with WHATISMYIP_ exist
    if env::vars().any(|(key, _)| key.starts_with("WHATISMYIP_")) {
        eprintln!("WHATISMYIP variables already exist. Skipping API call.");
        process::exit(1);
    }

    // 2. Validate arguments
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        eprintln!("Missing key");
        process::exit(1);
    }
    let key = &args[1];

    // Create a shared HTTP client with a User-Agent
    let client = reqwest::blocking::Client::builder()
        .user_agent("reqwest-agent/1.0")
        .build()?;

    // 3. First API Call: Get IP
    let wimip_url = format!("https://wimi-api.whatismyip.com/ip?key={}", key);
    let ip_res: IpResponse = client.get(&wimip_url).send()?.json()?;
    let ip_str = ip_res.ip;

    // 4. Second API Call: Get Meta Info
    let wimip_info_url = format!(
        "https://wimi-api.whatismyip.com/ip-address-lookup/{}?key={}",
        ip_str, key
    );
    
    // Parse response as an arbitrary JSON Object (Map) to mirror Perl's keys loop
    let info_res: serde_json::Map<String, serde_json::Value> = 
        client.get(&wimip_info_url).send()?.json()?;

    // 5. Output loop with string transformations
    for (name, val) in info_res {
        let upper_name = name.to_uppercase();
        // Extract raw string value out of JSON type safely
        if let Some(val_str) = val.as_str() {
            println!("export WHATISMYIP_{}=\"{}\"", upper_name, val_str);
        }
    }

    Ok(())
}

