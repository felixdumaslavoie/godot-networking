//! Note that the terms "client" and "server" here are purely what we logically associate with them.
//! Technically, they both work the same.
//! Note that in practice you don't want to implement a chat client using UDP.
use godot::prelude::*;
use std::thread;
use std::time::Duration;
use std::time::Instant;

use std::net::{IpAddr, Ipv4Addr, SocketAddr};

use laminar::{ErrorKind, Packet, Socket, SocketEvent};

mod consts;

fn client() -> Result<(), ErrorKind> {
    let addr: SocketAddr = SocketAddr::new(IpAddr::V4(Ipv4Addr::new(127, 0, 0, 1)), 6543);
    let mut socket = Socket::bind(addr)?;

    println!("Connected on {}", addr);

    let server: std::net::SocketAddr =
        SocketAddr::new(IpAddr::V4(Ipv4Addr::new(127, 0, 0, 1)), 6545);

    println!("Type a message and press Enter to send. Send `Bye!` to quit.");

    //let stdin = stdin();
    //let mut s_buffer = String::new();

    loop {
        //s_buffer.clear();
        //stdin.read_line(&mut s_buffer)?;
        //let line = s_buffer.replace(|x| x == '\n' || x == '\r', "");
        let la_chaine: String = "TEST".to_string();
        let payload: Vec<u8> = la_chaine.into_bytes();

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
}

#[derive(GodotClass)]
#[class(base=Node)]
struct Client {
    socket_address: SocketAddr,
}

#[godot_api]
impl INode for Client {
    fn init(base: Base<Node>) -> Self {
        godot_print!("Server node added!"); // Prints to the Godot console

        thread::spawn(client);

        godot_print!("Client thread spawned!"); // Prints to the Godot console
        Self {
            socket_address: SocketAddr::new(IpAddr::V4(Ipv4Addr::new(127, 0, 0, 1)), 6543),
        }
    }
}

// https://doc.rust-lang.org/book/ch16-01-threads.html
