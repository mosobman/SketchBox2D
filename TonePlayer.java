// For some systems where the processing sound library doesn't work - like mine //

import javax.sound.sampled.*;

public class TonePlayer {
    private SourceDataLine line;
    private Thread audioThread;
    private volatile boolean running;
    public volatile double targetAmplitude = 0.0;
    private double currentAmplitude = 1.0;
    private final double fadeStep = 0.0001; // smaller = smoother/faster
    public volatile double frequency = 440.0; // default A4
    private final float sampleRate = 44100f;

    // Start the audio thread and begin continuous tone
    public void startAudioThread() {
        if (running) return; // already running
        running = true;

        try {
            AudioFormat format = new AudioFormat(
                sampleRate,                         // sample rate
                16,                             // bits per sample
                1,                              // mono
                true,                           // signed
                false                           // little-endian
            );
            DataLine.Info info = new DataLine.Info(SourceDataLine.class, format);
            line = (SourceDataLine) AudioSystem.getLine(info);
            line.open(format);
            line.start();

            audioThread = new Thread(() -> {
                byte[] buffer = new byte[2*10];
                double phase = 0;
                double increment;

                while (running) {
                    increment = 2.0 * Math.PI * frequency / sampleRate;

                    for (int i = 0; i < buffer.length; i += 2) {
                        // sine wave in range -1.0..1.0, scaled by amplitude
                        float sampleValue = (float) (Math.sin(phase) * targetAmplitude);
                        short s = (short) (sampleValue * Short.MAX_VALUE);
                    
                        buffer[i]     = (byte) (s & 0xFF);
                        buffer[i + 1] = (byte) ((s >> 8) & 0xFF);
                    
                        // update amplitude gradually for smooth fade
                        if (currentAmplitude < targetAmplitude) {
                            currentAmplitude = Math.min(currentAmplitude + fadeStep, targetAmplitude);
                        } else if (currentAmplitude > targetAmplitude) {
                            currentAmplitude = Math.max(currentAmplitude - fadeStep, targetAmplitude);
                        }
                    
                        phase += increment;
                        if (phase > 2 * Math.PI) phase -= 2 * Math.PI;
                    }


                    line.write(buffer, 0, buffer.length);
                    Thread.yield(); // allow other threads (Processing) to run
                }
            });

            audioThread.start();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Stop the audio thread and release resources
    public void stopAudioThread() {
        running = false;
        try {
            if (audioThread != null) audioThread.join();
            audioThread = null;

            if (line != null) {
                line.stop();
                line.close();
                line = null;
            }
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    // Mute the tone (silence it)
    public void muteAudio() {
        targetAmplitude = 0.0;
    }

    // Unmute the tone (restore audio)
    public void unmuteAudio() {
        targetAmplitude = 1.0;
    }
    
    public void toggleAudio() {
      if (targetAmplitude > 0.5) muteAudio();
      else unmuteAudio();
    }

    // Optional: change frequency while playing
    public void setFrequency(double freq) {
        this.frequency = freq;
    }
}
