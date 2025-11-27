//! Fetch Prompt CLI tool.
//!
//! This tool fetches a webpage, extracts its content using readability,
//! and then sends a prompt to an LLM to process the content.

use std::io::{Cursor, Write};

use anyhow::Error;
use clap::Parser;
use futures::StreamExt;
use genai::{
    Client,
    chat::{ChatMessage, ChatRequest, ChatStreamEvent},
};
use readability::extractor;
use reqwest::Client as HttpClient;

#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
struct Cli {
    /// The URL to fetch and summarize
    url: String,

    /// The prompt to send to the LLM
    #[arg(
        short,
        long,
        default_value = "Summarize this article in 3 bullet points."
    )]
    prompt: String,

    /// The LLM model to use
    #[arg(short, long, default_value = "gpt-4o")]
    model: String,
}

#[tokio::main]
async fn main() -> Result<(), Error> {
    // 1. Get URL from args
    let cli = Cli::parse();
    let url = &cli.url;
    let user_prompt = &cli.prompt;

    println!("Fetching {url}");

    // 2. Fetch URL
    let http_client = HttpClient::new();
    let response = http_client.get(url).send().await?;
    let url_obj = reqwest::Url::parse(url)?;

    // Readability needs a reader. We'll read the full body into memory.
    let content_bytes = response.bytes().await?;
    let mut reader = Cursor::new(content_bytes);

    // 3. Extract Content
    // readability::extractor::extract(reader, url)
    // url is needed for resolving relative links
    let product = extractor::extract(&mut reader, &url_obj)?;

    println!("Title: {}", product.title);
    println!("Content Length: {} chars", product.text.len());
    println!("--------------------------------------------------");

    // 4. Prepare LLM Prompt
    let full_prompt = format!(
        "Here is the content of a webpage titled '{}':\n\n{}\n\n---\n\n{}",
        product.title, product.text, user_prompt
    );

    // 5. Call LLM
    let client = Client::default();

    // Check for API keys to decide default model, or just default to gpt-4o and let it fail if no key.
    // genai supports many providers. Let's try to be smart or just default to OpenAI.
    let model = &cli.model;

    println!("Sending to {model}...");

    let chat_req = ChatRequest::new(vec![ChatMessage::user(full_prompt)]);

    let mut stream = client.exec_chat_stream(model, chat_req, None).await?;

    println!("Response:");
    while let Some(chunk_res) = stream.stream.next().await {
        match chunk_res {
            Ok(ChatStreamEvent::Chunk(chunk)) => {
                print!("{}", chunk.content);
                std::io::stdout().flush()?;
            }
            Ok(_) => {
                // Ignore other events
            }
            Err(e) => {
                eprintln!("Error streaming response: {e}");
            }
        }
    }
    println!();

    Ok(())
}
