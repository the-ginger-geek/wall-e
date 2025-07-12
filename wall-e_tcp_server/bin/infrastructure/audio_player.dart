import 'dart:io';
import 'logger.dart';

/// Audio playback for TCP server
class AudioPlayer {
  static AudioPlayer? _instance;
  final String _soundFolder = "/home/admin/walle-replica/web_interface/static/sounds/";

  static AudioPlayer getInstance() {
    _instance ??= AudioPlayer._();
    return _instance!;
  }

  AudioPlayer._();

  /// Play a sound file
  Future<bool> playSound(String soundName) async {
    try {
      // Find the sound file
      String? soundFile = await _findSoundFile(soundName);
      
      if (soundFile != null && await File(soundFile).exists()) {
        // Play using aplay
        final result = await Process.run('aplay', [soundFile]);
        if (result.exitCode == 0) {
          Logger.writeLog('Playing sound: $soundName');
          return true;
        } else {
          Logger.writeLog('Failed to play sound: ${result.stderr}');
          return false;
        }
      } else {
        Logger.writeLog('Sound file not found: $soundName');
        return false;
      }
    } catch (e) {
      Logger.writeLog('Audio playback error: $e');
      return false;
    }
  }

  /// Convert text to speech and play
  Future<bool> textToSpeech(String text) async {
    try {
      // Use espeak for TTS
      final result = await Process.run('espeak-ng', [
        '-v', 'en',
        '-s', '150',
        text
      ]);
      
      if (result.exitCode == 0) {
        Logger.writeLog('Speaking: $text');
        return true;
      } else {
        Logger.writeLog('TTS error: ${result.stderr}');
        return false;
      }
    } catch (e) {
      Logger.writeLog('TTS error: $e');
      return false;
    }
  }

  /// Get list of available sounds
  Future<List<String>> getSoundList() async {
    try {
      final soundDir = Directory(_soundFolder);
      if (await soundDir.exists()) {
        final files = await soundDir.list().toList();
        final sounds = <String>[];
        
        for (final file in files) {
          if (file is File) {
            final fileName = file.path.split('/').last;
            if (fileName.endsWith('.wav') || fileName.endsWith('.mp3')) {
              sounds.add(fileName);
            }
          }
        }
        
        Logger.writeLog('Found ${sounds.length} sound files');
        return sounds;
      } else {
        Logger.writeLog('Sound directory not found: $_soundFolder');
        return [];
      }
    } catch (e) {
      Logger.writeLog('Sound list error: $e');
      return [];
    }
  }

  /// Find a sound file by name (partial matching)
  Future<String?> _findSoundFile(String soundName) async {
    try {
      final soundDir = Directory(_soundFolder);
      if (await soundDir.exists()) {
        final files = await soundDir.list().toList();
        
        for (final file in files) {
          if (file is File) {
            final fileName = file.path.split('/').last;
            if (fileName.startsWith(soundName) || 
                fileName.contains(soundName) ||
                soundName.toLowerCase() == fileName.toLowerCase().split('.').first) {
              return file.path;
            }
          }
        }
      }
      return null;
    } catch (e) {
      Logger.writeLog('Sound file search error: $e');
      return null;
    }
  }

  /// Play sound using Python subprocess for better compatibility
  Future<bool> playSoundViaPython(String soundName) async {
    try {
      final result = await Process.run('python3', [
        '-c',
        _audioProcessCommand,
        'play',
        soundName,
        _soundFolder
      ]);
      
      if (result.exitCode == 0) {
        Logger.writeLog('Playing sound via Python: $soundName');
        return true;
      } else {
        Logger.writeLog('Python audio error: ${result.stderr}');
        return false;
      }
    } catch (e) {
      Logger.writeLog('Python audio playback error: $e');
      return false;
    }
  }

  /// Text-to-speech using Python subprocess
  Future<bool> textToSpeechViaPython(String text) async {
    try {
      final result = await Process.run('python3', [
        '-c',
        _audioProcessCommand,
        'speak',
        text
      ]);
      
      if (result.exitCode == 0) {
        Logger.writeLog('Speaking via Python: $text');
        return true;
      } else {
        Logger.writeLog('Python TTS error: ${result.stderr}');
        return false;
      }
    } catch (e) {
      Logger.writeLog('Python TTS error: $e');
      return false;
    }
  }

  /// Get sound list using Python subprocess
  Future<List<String>> getSoundListViaPython() async {
    try {
      final result = await Process.run('python3', [
        '-c',
        _audioProcessCommand,
        'list',
        _soundFolder
      ]);
      
      if (result.exitCode == 0) {
        final output = result.stdout.toString().trim();
        if (output.isNotEmpty) {
          return output.split('\n').where((line) => line.isNotEmpty).toList();
        }
      }
      return [];
    } catch (e) {
      Logger.writeLog('Python sound list error: $e');
      return [];
    }
  }
}

/// Python code for audio operations
final _audioProcessCommand = '''
import sys
import os
import subprocess

def play_sound(sound_name, sound_folder):
    try:
        # Find the sound file
        sound_file = None
        for file in os.listdir(sound_folder):
            if file.startswith(sound_name) or sound_name in file:
                sound_file = os.path.join(sound_folder, file)
                break
                
        if sound_file and os.path.exists(sound_file):
            # Play using aplay
            subprocess.run(['aplay', sound_file], check=True)
            print(f"Playing: {sound_file}")
            return True
        else:
            print(f"Sound not found: {sound_name}")
            return False
            
    except Exception as e:
        print(f"Audio playback error: {e}")
        return False

def text_to_speech(text):
    try:
        # Use espeak for TTS
        subprocess.run(['espeak-ng', '-v', 'en', '-s', '150', text], check=True)
        print(f"Speaking: {text}")
        return True
    except Exception as e:
        print(f"TTS error: {e}")
        return False

def list_sounds(sound_folder):
    try:
        sounds = []
        if os.path.exists(sound_folder):
            for file in os.listdir(sound_folder):
                if file.endswith('.wav') or file.endswith('.mp3'):
                    sounds.append(file)
        
        for sound in sounds:
            print(sound)
        return True
    except Exception as e:
        print(f"Sound list error: {e}")
        return False

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python audio.py <command> [args...]")
        sys.exit(1)
    
    command = sys.argv[1]
    
    if command == "play" and len(sys.argv) >= 4:
        sound_name = sys.argv[2]
        sound_folder = sys.argv[3]
        play_sound(sound_name, sound_folder)
    elif command == "speak" and len(sys.argv) >= 3:
        text = " ".join(sys.argv[2:])
        text_to_speech(text)
    elif command == "list" and len(sys.argv) >= 3:
        sound_folder = sys.argv[2]
        list_sounds(sound_folder)
    else:
        print(f"Unknown command: {command}")
        sys.exit(1)
''';