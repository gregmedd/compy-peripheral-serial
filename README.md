# COMPY-V: UART / Serial Peripheral

UART peripheral for the COMPY-V system. Connects to the memory bus in any of the
peripheral slots. For example, the main console will be presented on the UART
connected to peripheral slot 1.

## Register Map

### 0x00 (0) - ID

The ID register is a standard part of the COMPY-V peripheral specification. It
is used to detect and identify the peripheral. All IDs have a magic number of
`0xA3`, and all UARTs have a type of `0x10`. Random unique IDs are assigned to
each instance of a peripheral so we can tell them apart.

    +------------------+------------------+------------------+------------------+
    | Magic            | Type             | CK | Unique ID                      |
    +------------------+------------------+------------------+------------------+
    31                                                                          0

The Magic number field can be used to scan the peripheral bus and identify when
a peripheral is connected to a given slot. The value of `0xA3` is chosen to have
a distinctive bit pattern (`0b10100011`).

The Type field tells the software what kind of peripheral is present in a given
slot. Character devices are `0x1X`, with UART being `0x10`.

The Check (CK) bits can be used to verify the contents of the ID register. The
upper check bit is odd parity for bits 16-31, while the lower check bit is odd
parity for bit 15 and bits 0-13.

The Unique ID field is randomly assigned and has no specific meaning. Zero is an
invalid ID value.

     MMMMMMMM   TTTTTTTT   CC IIIIIIIIIIIIII
    |--------| |--------| |-- --------------|
    31 |    24 23 |    16 15| 13|           0
       |          |         |   |
       |          |         |   +-- Randomly assigned unique serial number
       |          |         +------ Checksum bits
       |          +---------------- 0x10 (Character device, subtype UART)
       +--------------------------- 0xA3 (Peripheral magic number, fixed for all peripherals)

#### Check bit calculation

    b15 = not(xor(b31 ... b16))
    b14 = not(xor(not(b15), b13 ... b0))

TODO: Probablilites

### 0x04 (1) - Status

Operating status of the UART peripheral.

    +------------------+------------------+------------------+------------------+
    | TX Status        | RX Status        | Next TX Byte     | Last RX Byte     |
    +------------------+------------------+------------------+------------------+
    31                                                                          0

### 0x08 (2) - Interrupt Status

Interrupts that have occurred since the last time this register was read. All
interrupt flags are cleared when this register is read.

    +------------------+------------------+------------------+------------------+
    | Interrupts                          | RESERVED                            |
    +------------------+------------------+------------------+------------------+
    31                                                                          0

### 0x0C (3)
### 0x10 (4)
### 0x14 (5)
### 0x18 (6)
### 0x1C (7)

### 0x20 (8) - Config

    +------------------+------------------+------------------+------------------+
    | Framing          | RESERVED         | Bit Rate                            |
    +------------------+------------------+------------------+------------------+
    31                                                                          0

     D S PP R XXX   XXXXXXXX   XXXXXBBBBBBBBBBB
    |- - -- - ---| |--------| |----------------|
    31 | |  |  |     |          |    |         0
     | | |  |  |     |          |    |
     | | |  |  |     |          |    +-- Bit Rate in hundreds per second
     | | |  |  |     |          |        (75->0, 110->1, 150->2, 300->3, 600->6)
     | | |  |  |     |          +------- RESERVED (future use)
     | | |  |  |     +------------------ RESERVED (future use)
     | | |  |  +------------------------ RESERVED (future use)
     | | |  +--------------------------- RX Enable
     | | +------------------------------ Parity (None->00, Even->01, Odd->10)
     | +-------------------------------- Stop bits (One->0, Two->1)
     +---------------------------------- Data bits (Seven->0, Eight->1)

### 0x24 - Interrupt Config 0

    +------------------+------------------+------------------+------------------+
    | Controls                            | Watch Byte 0     | Watch Byte 1     |
    +------------------+------------------+------------------+------------------+
    31                                                                          0

     R T XXXXXXXX 0 1 2 3 4 5   ZZZZZZZZ   OOOOOOOO
    |- - -------- - - - - - -| |--------| |--------|
    31 |  |       | | | | | |    |          |      0
     | |  |       | | | | | |    |          |
     | |  |       | | | | | |    |          +-- Watch Byte One (1)
     | |  |       | | | | | |    +------------- Watch Byte Zero (0)
     | |  |       | | | | | +------------------ Interrupt on watch byte 5 match recieved
     | |  |       | | | | +-------------------- Interrupt on watch byte 4 match recieved
     | |  |       | | | +---------------------- Interrupt on watch byte 3 match recieved
     | |  |       | | +------------------------ Interrupt on watch byte 2 match recieved
     | |  |       | +-------------------------- Interrupt on watch byte 1 match recieved
     | |  |       +---------------------------- Interrupt on watch byte 0 match recieved
     | |  +------------------------------------ RESERVED (future use)
     | +--------------------------------------- Interrupt on transmit character complete
     +----------------------------------------- Interrupt on character receive

### 0x28 - Interrupt Config 1

    +------------------+------------------+------------------+------------------+
    | Watch Byte 2     | Watch Byte 3     | Watch Byte 4     | Watch Byte 5     |
    +------------------+------------------+------------------+------------------+
    31                                                                          0

### 0x2C - DMA Config 0

    +------------------+------------------+------------------+------------------+
    | TX Config        | RX Config        | RESERVED         | TX Byte IN       |
    +------------------+------------------+------------------+------------------+
    31                                                                          0

### 0x50 - DMA Config 1

    +------------------+------------------+------------------+------------------+
    | TX Buffer Start                                                           |
    +------------------+------------------+------------------+------------------+
    31                                                                          0

### 0x54 - DMA Config 2

    +------------------+------------------+------------------+------------------+
    | TX Buffer End                                                             |
    +------------------+------------------+------------------+------------------+
    31                                                                          0

### 0x58 - DMA Config 3

    +------------------+------------------+------------------+------------------+
    | RX Buffer Start                                                           |
    +------------------+------------------+------------------+------------------+
    31                                                                          0

### 0x5C - DMA Config 4

    +------------------+------------------+------------------+------------------+
    | RX Buffer End                                                             |
    +------------------+------------------+------------------+------------------+
    31                                                                          0

### 0x60 - TX DMA Ring Buffer 0

    +------------------+------------------+------------------+------------------+
    | TX Head Pointer                                                           |
    +------------------+------------------+------------------+------------------+
    31                                                                          0

### 0x64 - TX DMA Ring Buffer 1

    +------------------+------------------+------------------+------------------+
    | TX Tail Pointer                                                           |
    +------------------+------------------+------------------+------------------+
    31                                                                          0

### 0x68 - RX DMA Ring Buffer 0

    +------------------+------------------+------------------+------------------+
    | RX Head Pointer                                                           |
    +------------------+------------------+------------------+------------------+
    31                                                                          0

### 0x6C - RX DMA Ring Buffer 1

    +------------------+------------------+------------------+------------------+
    | RX Tail Pointer                                                           |
    +------------------+------------------+------------------+------------------+
    31                                                                          0

## Design

        Clock ───────┬──────────────────────────────────────────────┬────────────┐
                 ┌───▼────┐              ┌────────────────┐         │   ┌────────▼────────┐
                 │        │              │                │ Clock   │   │                 │
       Address   │        │   BitRate    │    Bitrate     │ Divide  │   │                 │
    ◄─────/─────►│   M    ├──────/──────►│    Decoder     ├───/──┬──┼──►│                 ├──────► TXD
         32      │   E    │      N       │                │   N  │  │   │   Transmitter   │
        Data     │   M    │              └────────────────┘      │  │   │                 │
    ◄─────/─────►│   O    │    Data                              │  │   │                 │
         32      │   R    ├──────/───────────────────┬───────────┼──┼──►│                 │
                 │   Y    │      8                   │           │  │   │                 │
        Read     │        │                          │           │  │   └─────────────────┘
    ────────────►│   I    │    ┌─────────────────┐   │           │  │             .
       Write     │   N    │◄──►│  CFG / Status   │...│...........│..│..............
    ────────────►│   T    │    └─────────────────┘   │           │  └───────────┐ .
        ACK      │   E    │                  .       │           │      ┌───────▼─────────┐
    ◄────────────│   R    │    Data          .       │           │      │                 │
                 │   F    │◄─────/───────────────┬───┼───────────┼──────┤                 │
      Rq. Read   │   A    │      8           .   ▼   ▼           │      │                 │◄────── RXD
    ◄────────────│   C    │              ┌───────────────┐       └─────►│    Receiver     │
      Rq. Write  │   E    │   MEMORY     │               │              │                 │
    ◄────────────│        │◄─────/──────►│      DMA      │              │                 │
       ACK Rq.   │        │      N       │    Adapter    │              │                 │
    ────────────►│        │              │               │              │                 │
                 └────────┘              └───────────────┘              └─────────────────┘
