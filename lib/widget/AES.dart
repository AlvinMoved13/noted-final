import 'dart:typed_data';

void main() {
  // Contoh penggunaan dengan plaintext dan kunci 256-bit
  Uint8List plaintext = Uint8List.fromList([
    0x32,
    0x88,
    0x31,
    0xe0,
    0x43,
    0x5a,
    0x31,
    0x37,
    0xf6,
    0x30,
    0x98,
    0x07,
    0xa8,
    0x8d,
    0xa2,
    0x34
  ]);
  Uint8List key = Uint8List.fromList([
    0x60,
    0x3d,
    0xeb,
    0x10,
    0x15,
    0xca,
    0x71,
    0xbe,
    0x2b,
    0x73,
    0xae,
    0xf0,
    0x85,
    0x7d,
    0x77,
    0x81,
    0x1f,
    0x35,
    0x2c,
    0x07,
    0x3b,
    0x61,
    0x08,
    0xd7,
    0x2d,
    0x98,
    0x10,
    0xa3,
    0x09,
    0x14,
    0xdf,
    0xf4,
  ]);

  // Menampilkan plaintext dan kunci awal
  print(
      "Plaintext: ${plaintext.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ')}");
  print(
      "Key: ${key.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ')}");

  // Langkah 1: Key Expansion
  List<Uint8List> roundKeys = keyExpansion(key);

  // Langkah 2: Initial Round (AddRoundKey)
  addRoundKey(plaintext, roundKeys.sublist(0, 4));

  // Langkah 3: Rounds (14 putaran untuk AES-256)
  for (int round = 1; round < 14; round++) {
    subBytes(plaintext);
    shiftRows(plaintext);
    mixColumns(plaintext);
    addRoundKey(plaintext, roundKeys.sublist(round * 4, (round + 1) * 4));
  }

  // Langkah 4: Final Round
  subBytes(plaintext);
  shiftRows(plaintext);
  addRoundKey(plaintext, roundKeys.sublist(14 * 4, 15 * 4));

  // Hasil akhir ciphertext
  print(
      "Ciphertext: ${plaintext.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ')}");
}

// Langkah 1: Key Expansion
List<Uint8List> keyExpansion(Uint8List key) {
  List<Uint8List> roundKeys = [key];

  for (int i = 0; i < 14; i++) {
    Uint8List prevKey = roundKeys[i];
    Uint8List newKey = Uint8List(16);

    // Kunci ke-4, ke-8, ke-12, dst. mengalami transformasi khusus
    if (i % 4 == 0) {
      // Rotasi byte ke kiri
      Uint8List rotatedWord =
          Uint8List.fromList([prevKey[1], prevKey[2], prevKey[3], prevKey[0]]);

      // SubBytes
      for (int j = 0; j < 4; j++) {
        rotatedWord[j] = sBox[rotatedWord[j]];
      }

      // XOR dengan konstanta rcon
      rotatedWord[0] ^= rcon[i ~/ 4];

      // XOR dengan kunci sebelumnya
      for (int j = 0; j < 4; j++) {
        newKey[j] = rotatedWord[j] ^ prevKey[j];
      }

      // XOR sisa byte kunci
      for (int j = 4; j < 16; j++) {
        newKey[j] = newKey[j - 4] ^ prevKey[j];
      }
    } else {
      // XOR dengan kunci sebelumnya
      for (int j = 0; j < 16; j++) {
        newKey[j] = prevKey[j] ^ roundKeys[i - 1][j];
      }
    }

    roundKeys.add(newKey);
  }

  return roundKeys;
}

// Langkah 2: Initial Round (AddRoundKey)
void addRoundKey(Uint8List state, List<Uint8List> roundKeys) {
  for (int i = 0; i < 16; i++) {
    state[i] ^= roundKeys[i ~/ 4][i % 4];
  }
}

// Langkah 3: SubBytes
void subBytes(Uint8List state) {
  for (int i = 0; i < state.length; i++) {
    state[i] = sBox[state[i]];
  }
}

// Langkah 3: ShiftRows
void shiftRows(Uint8List state) {
  Uint8List temp = Uint8List(16);

  // Baris pertama tidak bergeser
  temp[0] = state[0];
  temp[1] = state[5];
  temp[2] = state[10];
  temp[3] = state[15];

  // Geser baris kedua
  temp[4] = state[4];
  temp[5] = state[9];
  temp[6] = state[14];
  temp[7] = state[3];

  // Geser baris ketiga
  temp[8] = state[8];
  temp[9] = state[13];
  temp[10] = state[2];
  temp[11] = state[7];

  // Geser baris keempat
  temp[12] = state[12];
  temp[13] = state[1];
  temp[14] = state[6];
  temp[15] = state[11];

  // Salin hasil geser ke state
  for (int i = 0; i < state.length; i++) {
    state[i] = temp[i];
  }
}

// Langkah 3: MixColumns
void mixColumns(Uint8List state) {
  for (int i = 0; i < 4; i++) {
    int s0 = state[i];
    int s1 = state[i + 4];
    int s2 = state[i + 8];
    int s3 = state[i + 12];

    state[i] = gmul(0x02, s0) ^ gmul(0x03, s1) ^ s2 ^ s3;
    state[i + 4] = s0 ^ gmul(0x02, s1) ^ gmul(0x03, s2) ^ s3;
    state[i + 8] = s0 ^ s1 ^ gmul(0x02, s2) ^ gmul(0x03, s3);
    state[i + 12] = gmul(0x03, s0) ^ s1 ^ s2 ^ gmul(0x02, s3);
  }
}

// Fungsi perkalian Galois
int gmul(int a, int b) {
  int p = 0;
  for (int i = 0; i < 8; i++) {
    if ((b & 1) == 1) {
      p ^= a;
    }
    bool highBitSet = (a & 0x80) == 0x80;
    a <<= 1;
    if (highBitSet) {
      a ^= 0x1b; // XOR dengan 0x1b jika bit tertinggi setelah shift
    }
    b >>= 1;
  }
  return p % 256;
}

// Tabel Substitusi (S-box)
List<int> sBox = [
  0x63,
  0x7c,
  0x77,
  0x7b,
  0xf2,
  0x6b,
  0x6f,
  0xc5,
  0x30,
  0x01,
  0x67,
  0x2b,
  0xfe,
  0xd7,
  0xab,
  0x76,
  0xca,
  0x82,
  0xc9,
  0x7d,
  0xfa,
  0x59,
  0x47,
  0xf0,
  0xad,
  0xd4,
  0xa2,
  0xaf,
  0x9c,
  0xa4,
  0x72,
  0xc0,
  0xb7,
  0xfd,
  0x93,
  0x26,
  0x36,
  0x3f,
  0xf7,
  0xcc,
  0x34,
  0xa5,
  0xe5,
  0xf1,
  0x71,
  0xd8,
  0x31,
  0x15,
  0x04,
  0xc7,
  0x23,
  0xc3,
  0x18,
  0x96,
  0x05,
  0x9a,
  0x07,
  0x12,
  0x80,
  0xe2,
  0xeb,
  0x27,
  0xb2,
  0x75,
  0x09,
  0x83,
  0x2c,
  0x1a,
  0x1b,
  0x6e,
  0x5a,
  0xa0,
  0x52,
  0x3b,
  0xd6,
  0xb3,
  0x29,
  0xe3,
  0x2f,
  0x84,
  0x53,
  0xd1,
  0x00,
  0xed,
  0x20,
  0xfc,
  0xb1,
  0x5b,
  0x6a,
  0xcb,
  0xbe,
  0x39,
  0x4a,
  0x4c,
  0x58,
  0xcf,
  0xd0,
  0xef,
  0xaa,
  0xfb,
  0x43,
  0x4d,
  0x33,
  0x85,
  0x45,
  0xf9,
  0x02,
  0x7f,
  0x50,
  0x3c,
  0x9f,
  0xa8,
  0x51,
  0xa3,
  0x40,
  0x8f,
  0x92,
  0x9d,
  0x38,
  0xf5,
  0xbc,
  0xb6,
  0xda,
  0x21,
  0x10,
  0xff,
  0xf3,
  0xd2,
  0xcd,
  0x0c,
  0x13,
  0xec,
  0x5f,
  0x97,
  0x44,
  0x17,
  0xc4,
  0xa7,
  0x7e,
  0x3d,
  0x64,
  0x5d,
  0x19,
  0x73,
  0x60,
  0x81,
  0x4f,
  0xdc,
  0x22,
  0x2a,
  0x90,
  0x88,
  0x46,
  0xee,
  0xb8,
  0x14,
  0xde,
  0x5e,
  0x0b,
  0xdb,
  0xe0,
  0x32,
  0x3a,
  0x0a,
  0x49,
  0x06,
  0x24,
  0x5c,
  0xc2,
  0xd3,
  0xac,
  0x62,
  0x91,
  0x95,
  0xe4,
  0x79,
  0xe7,
  0xc8,
  0x37,
  0x6d,
  0x8d,
  0xd5,
  0x4e,
  0xa9,
  0x6c,
  0x56,
  0xf4,
  0xea,
  0x65,
  0x7a,
  0xae,
  0x08,
  0xba,
  0x78,
  0x25,
  0x2e,
  0x1c,
  0xa6,
  0xb4,
  0xc6,
  0xe8,
  0xdd,
  0x74,
  0x1f,
  0x4b,
  0xbd,
  0x8b,
  0x8a,
  0x70,
  0x3e,
  0xb5,
  0x66,
  0x48,
  0x03,
  0xf6,
  0x0e,
  0x61,
  0x35,
  0x57,
  0xb9,
  0x86,
  0xc1,
  0x1d,
  0x9e,
  0xe1,
  0xf8,
  0x98,
  0x11,
  0x69,
  0xd9,
  0x8e,
  0x94,
  0x9b,
  0x1e,
  0x87,
  0xe9,
  0xce,
  0x55,
  0x28,
  0xdf,
  0x8c,
  0xa1,
  0x89,
  0x0d,
  0xbf,
  0xe6,
  0x42,
  0x68,
  0x41,
  0x99,
  0x2d,
  0x0f,
  0xb0,
  0x54,
  0xbb,
  0x16,
];

// Tabel konstanta rcon
List<int> rcon = [
  0x01,
  0x02,
  0x04,
  0x08,
  0x10,
  0x20,
  0x40,
  0x80,
  0x1B,
  0x36,
  0x6c,
  0xd8,
  0xab,
  0x4d,
  0x9a
];
