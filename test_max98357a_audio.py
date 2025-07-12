#!/usr/bin/env python3

"""
Test script for MAX98357A amplifier audio playback
Tests various audio formats and playback scenarios
"""

import os
import sys
import subprocess
import time
import logging
import glob
from pathlib import Path

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class MAX98357ATest:
    def __init__(self):
        self.device = "max98357a"
        self.sample_rate = 44100
        self.channels = 2
        self.bit_depth = 16
        self.sounds_dir = "web_interface/static/sounds"
        
    def check_audio_devices(self):
        """Check available audio devices"""
        logger.info("Checking available audio devices...")
        try:
            result = subprocess.run(['aplay', '-l'], capture_output=True, text=True)
            logger.info(f"Available audio devices:\n{result.stdout}")
            return result.returncode == 0
        except Exception as e:
            logger.error(f"Error checking audio devices: {e}")
            return False
    
    def check_alsa_config(self):
        """Check ALSA configuration"""
        logger.info("Checking ALSA configuration...")
        try:
            result = subprocess.run(['aplay', '-L'], capture_output=True, text=True)
            logger.info(f"ALSA PCM devices:\n{result.stdout}")
            
            # Check if max98357a device is available
            if "max98357a" in result.stdout:
                logger.info("MAX98357A device found in ALSA configuration")
                return True
            else:
                logger.warning("MAX98357A device not found in ALSA configuration")
                return False
        except Exception as e:
            logger.error(f"Error checking ALSA config: {e}")
            return False
    
    def generate_test_tone(self, frequency=440, duration=2, output_file="test_tone.wav"):
        """Generate a test tone using sox"""
        logger.info(f"Generating {frequency}Hz test tone for {duration} seconds...")
        try:
            cmd = [
                'sox', '-n', '-r', str(self.sample_rate), '-c', str(self.channels),
                output_file, 'synth', str(duration), 'sine', str(frequency)
            ]
            result = subprocess.run(cmd, capture_output=True, text=True)
            if result.returncode == 0:
                logger.info(f"Test tone generated: {output_file}")
                return True
            else:
                logger.error(f"Error generating test tone: {result.stderr}")
                return False
        except FileNotFoundError:
            logger.warning("sox not found, attempting alternative method...")
            return self.generate_test_tone_alternative(frequency, duration, output_file)
        except Exception as e:
            logger.error(f"Error generating test tone: {e}")
            return False
    
    def generate_test_tone_alternative(self, frequency=440, duration=2, output_file="test_tone.wav"):
        """Generate test tone using speaker-test"""
        logger.info("Attempting to use speaker-test for audio generation...")
        try:
            # Use speaker-test to generate audio directly to device
            cmd = ['speaker-test', '-D', 'plughw:0,0', '-t', 'sine', '-f', str(frequency), '-l', '1']
            logger.info(f"Running: {' '.join(cmd)}")
            result = subprocess.run(cmd, timeout=duration+1)
            return True
        except subprocess.TimeoutExpired:
            logger.info("Speaker test completed")
            return True
        except Exception as e:
            logger.error(f"Error with speaker-test: {e}")
            return False
    
    def play_audio_file(self, audio_file, device=None):
        """Play audio file through specified device"""
        if not os.path.exists(audio_file):
            logger.error(f"Audio file not found: {audio_file}")
            return False
        
        if device is None:
            device = f"plughw:0,0"  # Default to card 0, device 0
        
        logger.info(f"Playing {audio_file} through device {device}...")
        try:
            cmd = ['aplay', '-D', device, audio_file]
            result = subprocess.run(cmd, capture_output=True, text=True)
            if result.returncode == 0:
                logger.info("Audio playback completed successfully")
                return True
            else:
                logger.error(f"Error playing audio: {result.stderr}")
                return False
        except Exception as e:
            logger.error(f"Error playing audio file: {e}")
            return False
    
    def test_volume_levels(self):
        """Test different volume levels"""
        logger.info("Testing volume levels...")
        try:
            # Get current volume
            result = subprocess.run(['amixer', 'get', 'Master'], capture_output=True, text=True)
            logger.info(f"Current mixer settings:\n{result.stdout}")
            
            # Test different volume levels
            volumes = [25, 50, 75, 100]
            for vol in volumes:
                logger.info(f"Setting volume to {vol}%...")
                subprocess.run(['amixer', 'set', 'Master', f'{vol}%'], capture_output=True)
                time.sleep(0.5)
                
            logger.info("Volume level test completed")
            return True
        except Exception as e:
            logger.error(f"Error testing volume levels: {e}")
            return False
    
    def test_gpio_control(self):
        """Test GPIO control for MAX98357A shutdown pin"""
        logger.info("Testing GPIO control (SD_MODE pin)...")
        try:
            # Check current GPIO status
            result = subprocess.run(['cat', '/sys/kernel/debug/gpio'], capture_output=True, text=True)
            if 'gpio-516' in result.stdout:
                gpio_line = [line for line in result.stdout.split('\n') if 'gpio-516' in line][0]
                logger.info(f"Current GPIO4 status: {gpio_line.strip()}")
                
                if 'out lo' in gpio_line:
                    logger.warning("GPIO4 (SD_MODE) is LOW - amplifier is disabled!")
                    logger.info("Attempting to enable amplifier...")
                    
                    # Try to enable using device tree control
                    try:
                        # The GPIO is controlled by the device tree overlay
                        # We need to check if it can be controlled via sysfs
                        result = subprocess.run(['echo', '1'], capture_output=True, text=True)
                        logger.info("GPIO4 is controlled by device tree overlay")
                        logger.info("Try: sudo dtoverlay -r max98357a && sudo dtoverlay max98357a")
                        return False
                    except Exception:
                        pass
                elif 'out hi' in gpio_line:
                    logger.info("GPIO4 (SD_MODE) is HIGH - amplifier should be enabled")
                    return True
            
            logger.warning("Could not determine GPIO4 status")
            return False
            
        except Exception as e:
            logger.error(f"Error testing GPIO control: {e}")
            return False
    
    def discover_sound_files(self):
        """Discover available sound files in the sounds directory"""
        logger.info(f"Discovering sound files in {self.sounds_dir}...")
        
        sound_files = []
        if os.path.exists(self.sounds_dir):
            # Look for common audio file extensions
            extensions = ['*.wav', '*.mp3', '*.ogg', '*.flac', '*.aac']
            for ext in extensions:
                pattern = os.path.join(self.sounds_dir, ext)
                sound_files.extend(glob.glob(pattern))
            
            logger.info(f"Found {len(sound_files)} sound files:")
            for i, file in enumerate(sound_files, 1):
                filename = os.path.basename(file)
                logger.info(f"  {i}: {filename}")
        else:
            logger.warning(f"Sounds directory not found: {self.sounds_dir}")
        
        return sound_files
    
    def play_sound_file(self, sound_file, device=None):
        """Play a specific sound file"""
        if device is None:
            device = "plughw:1,0"  # MAX98357A is on card 1
        
        full_path = os.path.join(self.sounds_dir, sound_file) if not sound_file.startswith('/') else sound_file
        return self.play_audio_file(full_path, device)
    
    def play_all_sounds(self, device=None, delay=1):
        """Play all discovered sound files with delay between each"""
        sound_files = self.discover_sound_files()
        
        if not sound_files:
            logger.warning("No sound files found to play")
            return False
        
        success_count = 0
        for sound_file in sound_files:
            filename = os.path.basename(sound_file)
            logger.info(f"Playing: {filename}")
            
            if self.play_audio_file(sound_file, device):
                success_count += 1
            else:
                logger.error(f"Failed to play: {filename}")
            
            if delay > 0:
                time.sleep(delay)
        
        logger.info(f"Successfully played {success_count}/{len(sound_files)} sound files")
        return success_count == len(sound_files)
    
    def interactive_sound_player(self):
        """Interactive sound file player"""
        sound_files = self.discover_sound_files()
        
        if not sound_files:
            logger.error("No sound files found")
            return
        
        device = "plughw:1,0"  # MAX98357A device
        
        while True:
            print("\n" + "="*50)
            print("Interactive Sound Player - MAX98357A")
            print("="*50)
            
            for i, file in enumerate(sound_files, 1):
                filename = os.path.basename(file)
                print(f"{i:2}: {filename}")
            
            print(" a: Play all sounds")
            print(" q: Quit")
            print("="*50)
            
            try:
                choice = input("Select sound to play: ").strip().lower()
                
                if choice == 'q':
                    break
                elif choice == 'a':
                    self.play_all_sounds(device, delay=0.5)
                elif choice.isdigit():
                    index = int(choice) - 1
                    if 0 <= index < len(sound_files):
                        self.play_audio_file(sound_files[index], device)
                    else:
                        print("Invalid selection")
                else:
                    print("Invalid input")
                    
            except KeyboardInterrupt:
                print("\nExiting...")
                break
            except Exception as e:
                logger.error(f"Error in interactive player: {e}")
    
    def run_comprehensive_test(self):
        """Run comprehensive audio test suite"""
        logger.info("Starting comprehensive MAX98357A audio test...")
        
        test_results = {}
        
        # Test 1: Check audio devices
        test_results['audio_devices'] = self.check_audio_devices()
        
        # Test 2: Check ALSA configuration
        test_results['alsa_config'] = self.check_alsa_config()
        
        # Test 3: GPIO control test
        test_results['gpio_control'] = self.test_gpio_control()
        
        # Test 4: Volume level test
        test_results['volume_levels'] = self.test_volume_levels()
        
        # Test 5: Generate and play test tones
        test_tones = [440, 1000, 2000]  # A4, 1kHz, 2kHz
        test_results['tone_generation'] = True
        test_results['tone_playback'] = True
        
        for freq in test_tones:
            tone_file = f"test_tone_{freq}hz.wav"
            if self.generate_test_tone(freq, 2, tone_file):
                if not self.play_audio_file(tone_file):
                    test_results['tone_playback'] = False
            else:
                test_results['tone_generation'] = False
            
            # Clean up
            if os.path.exists(tone_file):
                os.remove(tone_file)
        
        # Test 6: Alternative speaker test if tone generation failed
        if not test_results['tone_generation']:
            logger.info("Running alternative speaker test...")
            test_results['speaker_test'] = self.generate_test_tone_alternative()
        
        # Print results
        logger.info("\n" + "="*50)
        logger.info("TEST RESULTS SUMMARY")
        logger.info("="*50)
        for test_name, result in test_results.items():
            status = "PASS" if result else "FAIL"
            logger.info(f"{test_name:<20}: {status}")
        logger.info("="*50)
        
        overall_success = all(test_results.values())
        if overall_success:
            logger.info("✓ All tests passed! MAX98357A amplifier is working correctly.")
        else:
            logger.warning("⚠ Some tests failed. Check the logs above for details.")
        
        return overall_success

def main():
    """Main function"""
    logger.info("MAX98357A Audio Amplifier Test Script")
    logger.info("=====================================")
    
    tester = MAX98357ATest()
    
    if len(sys.argv) > 1:
        command = sys.argv[1].lower()
        
        if command == 'devices':
            tester.check_audio_devices()
        elif command == 'config':
            tester.check_alsa_config()
        elif command == 'tone':
            freq = int(sys.argv[2]) if len(sys.argv) > 2 else 440
            duration = int(sys.argv[3]) if len(sys.argv) > 3 else 2
            tone_file = "test_tone.wav"
            if tester.generate_test_tone(freq, duration, tone_file):
                tester.play_audio_file(tone_file)
                os.remove(tone_file)
        elif command == 'play':
            if len(sys.argv) > 2:
                tester.play_audio_file(sys.argv[2])
            else:
                logger.error("Please specify audio file to play")
        elif command == 'volume':
            tester.test_volume_levels()
        elif command == 'gpio':
            tester.test_gpio_control()
        elif command == 'sounds':
            tester.discover_sound_files()
        elif command == 'playsounds':
            tester.play_all_sounds()
        elif command == 'playsound':
            if len(sys.argv) > 2:
                tester.play_sound_file(sys.argv[2])
            else:
                logger.error("Please specify sound file name to play")
        elif command == 'interactive':
            tester.interactive_sound_player()
        elif command == 'all':
            tester.run_comprehensive_test()
        else:
            print("Usage: python3 test_max98357a_audio.py [command]")
            print("Commands:")
            print("  devices      - Check available audio devices")
            print("  config       - Check ALSA configuration")
            print("  tone [freq] [duration] - Generate and play test tone")
            print("  play [file]  - Play audio file")
            print("  volume       - Test volume levels")
            print("  sounds       - Discover available sound files")
            print("  playsounds   - Play all sound files")
            print("  playsound [name] - Play specific sound file")
            print("  interactive  - Interactive sound player")
            print("  gpio     - Test GPIO control")
            print("  all      - Run comprehensive test suite")
    else:
        # Run comprehensive test by default
        tester.run_comprehensive_test()

if __name__ == "__main__":
    main()