import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

void main() {
  final outputDir = Directory('assets/sounds');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  // Generate sounds
  writeWavFile('${outputDir.path}/click.wav', generateClickSamples());
  writeWavFile('${outputDir.path}/error.wav', generateErrorSamples());
  writeWavFile('${outputDir.path}/success.wav', generateSuccessSamples());

  print('Sound files generated successfully.');
}

void writeWavFile(String path, List<int> pcmSamples) {
  final sampleCount = pcmSamples.length;
  final byteCount = sampleCount; // 8-bit mono
  final header = ByteData(44);

  // RIFF header
  header.setUint8(0, 0x52); // 'R'
  header.setUint8(1, 0x49); // 'I'
  header.setUint8(2, 0x46); // 'F'
  header.setUint8(3, 0x46); // 'F'
  header.setUint32(4, 36 + byteCount, Endian.little); // Chunk size
  header.setUint8(8, 0x57); // 'W'
  header.setUint8(9, 0x41); // 'A'
  header.setUint8(10, 0x56); // 'V'
  header.setUint8(11, 0x45); // 'E'

  // fmt subchunk
  header.setUint8(12, 0x66); // 'f'
  header.setUint8(13, 0x6d); // 'm'
  header.setUint8(14, 0x74); // 't'
  header.setUint8(15, 0x20); // ' '
  header.setUint32(16, 16, Endian.little); // Subchunk size (16 for PCM)
  header.setUint16(20, 1, Endian.little); // Audio format (1 = PCM)
  header.setUint16(22, 1, Endian.little); // Number of channels (1 = mono)
  header.setUint32(24, 22050, Endian.little); // Sample rate (22050 Hz)
  header.setUint32(28, 22050, Endian.little); // Byte rate (SampleRate * ChannelCount * BytesPerSample)
  header.setUint16(32, 1, Endian.little); // Block align
  header.setUint16(34, 8, Endian.little); // Bits per sample (8-bit)

  // data subchunk
  header.setUint8(36, 0x64); // 'd'
  header.setUint8(37, 0x61); // 'a'
  header.setUint8(38, 0x74); // 't'
  header.setUint8(39, 0x61); // 'a'
  header.setUint32(40, byteCount, Endian.little); // Data size

  final fileBytes = BytesBuilder();
  fileBytes.add(header.buffer.asUint8List());
  fileBytes.add(pcmSamples);

  File(path).writeAsBytesSync(fileBytes.toBytes());
}

List<int> generateClickSamples() {
  const sampleRate = 22050;
  const duration = 0.04; // 40ms
  final numSamples = (sampleRate * duration).toInt();
  final List<int> samples = List.filled(numSamples, 128);

  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    // Decaying envelope
    final envelope = exp(-200.0 * t);
    // Smooth frequency decay (high pitch transition to low pitch click)
    final freq = 1200.0 - (600.0 * (i / numSamples));
    final val = sin(2 * pi * freq * t);
    samples[i] = (128 + (val * envelope * 127)).clamp(0, 255).toInt();
  }
  return samples;
}

List<int> generateErrorSamples() {
  const sampleRate = 22050;
  const duration = 0.18; // 180ms
  final numSamples = (sampleRate * duration).toInt();
  final List<int> samples = List.filled(numSamples, 128);

  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    // Envelope for a quick rise and slow fall
    final envelope = (t < 0.02) ? (t / 0.02) : exp(-15.0 * (t - 0.02));
    // Low frequency buzzing noise
    final freq = 130.0 + (30.0 * sin(2 * pi * 80.0 * t)); // frequency modulation
    final val = sin(2 * pi * freq * t) > 0.0 ? 1.0 : -1.0; // square-ish wave for buzz
    samples[i] = (128 + (val * envelope * 80)).clamp(0, 255).toInt();
  }
  return samples;
}

List<int> generateSuccessSamples() {
  const sampleRate = 22050;
  const duration = 0.5; // 500ms
  final numSamples = (sampleRate * duration).toInt();
  final List<int> samples = List.filled(numSamples, 128);

  // Arpeggio / Chords: C5 (523Hz), E5 (659Hz), G5 (784Hz), C6 (1046Hz)
  final frequencies = [523.25, 659.25, 783.99, 1046.50];

  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final envelope = exp(-5.0 * t);
    double sum = 0.0;

    // Mix overlapping tones
    for (int n = 0; n < frequencies.length; n++) {
      // stagger notes slightly
      final delay = n * 0.06;
      if (t >= delay) {
        sum += sin(2 * pi * frequencies[n] * (t - delay));
      }
    }

    final val = sum / frequencies.length;
    samples[i] = (128 + (val * envelope * 127)).clamp(0, 255).toInt();
  }
  return samples;
}
