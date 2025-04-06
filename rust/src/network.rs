//! Note that the terms "client" and "server" here are purely what we logically associate with them.
//! Technically, they both work the same.
//! Note that in practice you don't want to implement a chat client using UDP.
use godot::prelude::*;
use std::time::Instant;
use std::{io::stdin, time::Duration};

use laminar::{ErrorKind, Packet, Socket, SocketEvent};

mod consts;

fn client() -> Result<(), ErrorKind> {
    let addr = "127.0.0.1:12352";
    let mut socket = Socket::bind(addr)?;

    println!("Connected on {}", addr);

    let server: std::net::SocketAddr = consts::SERVER.parse().unwrap();

    println!("Type a message and press Enter to send. Send `Bye!` to quit.");

    //let stdin = stdin();
    //let mut s_buffer = String::new();

    loop {
        //s_buffer.clear();
        //stdin.read_line(&mut s_buffer)?;
        //let line = s_buffer.replace(|x| x == '\n' || x == '\r', "");

        let payload: Vec<u8> = "TEST".into();

        socket.send(Packet::reliable_unordered(server, payload))?;

        socket.manual_poll(Instant::now());

        match socket.recv() {
            Some(SocketEvent::Packet(packet)) => {
                if packet.addr() == server {
                    println!("Server sent: {}", String::from_utf8_lossy(packet.payload()));
                } else {
                    println!("Unknown sender.");
                }
            }
            Some(SocketEvent::Timeout(_)) => {}
            _ => println!("Silence.."),
        }
        std::thread::sleep(Duration::from_millis(1000));
    }

    Ok(())
}

fn printer() {
    loop {
        println!("In loop!"); // Prints to the Godot console
        std::thread::sleep(Duration::from_millis(1000));
    }
}

fn initClient() {
    println!("Initiating client on port 12352"); // Prints to the Godot console
    client();
}

#[derive(GodotClass)]
#[class(base=Node)]
struct Client {
    server_address: String,
    server_port: String,
    client_port: String,
}

#[godot_api]
impl INode for Client {
    fn init(base: Base<Node>) -> Self {
        godot_print!("Server node added!"); // Prints to the Godot console

        //std::thread::spawn(initClient);
        godot_print!("Client thread spawned!"); // Prints to the Godot console

        Client {}
    }
}

impl Client {}
