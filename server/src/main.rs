//! Note that the terms "client" and "server" here are purely what we logically associate with them.
//! Technically, they both work the same.
//! Note that in practice you don't want to implement a chat client using UDP.
use std::net::{IpAddr, Ipv4Addr, SocketAddr};
use std::thread;

use laminar::{ErrorKind, Packet, Socket, SocketEvent};

const SERVER: std::net::SocketAddr = SocketAddr::new(IpAddr::V4(Ipv4Addr::new(127, 0, 0, 1)), 6545);

fn server() -> Result<(), ErrorKind> {
    let mut socket = Socket::bind(SERVER)?;
    let (sender, receiver) = (socket.get_packet_sender(), socket.get_event_receiver());
    let _thread = thread::spawn(move || socket.start_polling());

    loop {
        if let Ok(event) = receiver.recv() {
            match event {
                SocketEvent::Packet(packet) => {
                    let msg = packet.payload();

                    if msg == b"Bye!" {
                        break;
                    }

                    let msg = String::from_utf8_lossy(msg);
                    let ip = packet.addr().ip();

                    println!("Received {:?} from {:?}", msg, ip);

                    sender
                        .send(Packet::reliable_unordered(
                            packet.addr(),
                            "Copy that!".as_bytes().to_vec(),
                        ))
                        .expect("This should send");
                }
                SocketEvent::Timeout(address) => {
                    println!("Client timed out: {}", address);
                }
                _ => {}
            }
        }
    }

    Ok(())
}

fn main() -> Result<(), ErrorKind> {
    //let stdin = stdin();

    println!("Starting server..");
    server()
}
