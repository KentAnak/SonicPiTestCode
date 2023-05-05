use_bpm 130

# Chords
chord_am = chord(:A3, :minor)
chord_f = chord(:f3, :major)
chord_g = chord(:g3, :m7)
chord_c = chord(:c3, :major)

# Chord progression
chord_progression = [chord_am, chord_f, chord_g, chord_c]

define :chord_player do |chord_name|
  use_synth :piano
  play chord_name, sustain: 1, amp: 2.5
  sleep 1
  play chord_name, sustain: 1, amp: 2.5
  sleep 1
end

define :play_melody do |melody_note|
  use_synth :organ_tonewheel
  play melody_note, sustain: 0.45, release: 0.45, amp: 0.4
  sleep 0.5
end

define :play_sphere do |melody_note|
  use_synth :dark_ambience
  play melody_note, sustain: 3.0, amp: 2
  sleep 4
end

# Sphere
live_loop :sphere do
  4.times do
    chord_progression.each do |chord|
      play_sphere chord
    end
  end
end

live_loop :piano_melody do
  1.times do
    chord_progression.each do |chord|
      chord_player chord
      root_note = chord[0]
      scale_type = chord.to_s.include?("a") ? :minor_pentatonic : :major_pentatonic
      melody_notes = scale(root_note + 12, scale_type).take(8).values_at(5,5,1,0)
      melody_notes.each do |melody_note|
        play_melody melody_note
      end
    end
  end
  cue :kick_cue
end

# Kick
live_loop :kick, sync: :kick_cue do
  8.times do
    sample :bd_haus, amp: 2.0
    sleep 1
    sample :bd_haus, amp: 2.0
    sleep 1
  end
  cue :bass_cue
end

# Bass
bass_counter = 0
live_loop :bass, sync: :bass_cue do
  if bass_counter < 8
    use_synth :fm
    use_synth_defaults attack: 0.05, release: 0.45, amp: 1.5
    
    chord_progression.each_with_index do |chord, chord_index|
      base_note = chord[0]
      
      8.times do |i|
        if chord_index == 2
          pattern = [0, 0, 1, 0, 3, 2, 1, 0]
          play chord[pattern[i]]
          sleep 0.5
        elsif chord_index == 3
          pattern = [0, 0, 0, 0, 0, 0, 1, 0]
          play chord[pattern[i]]
          sleep 0.5
        else
          pattern = [0, 0, 2, 0, 0, 0, 0, 0]
          play chord[pattern[i]]
          sleep 0.5
        end
      end
    end
    bass_counter += 1
    cue :snare_and_hihat
  else
    stop
  end
end

# Snare
live_loop :snare do
  sync :snare_and_hihat
  sleep 0.5
  sample :perc_snap, amp: 1.5
  sleep 0.5
  sample :perc_snap, amp: 1.5
  sleep 1.5
end

# Hi-hat
live_loop :hihat do
  sync :snare_and_hihat
  sample :drum_cymbal_closed, amp: 0.8
  sleep 0.25
  sample :drum_cymbal_pedal, amp: 0.8
  sleep 0.25
  sample :drum_cymbal_closed, amp: 0.8
  sleep 0.25
  sample :drum_cymbal_pedal, amp: 0.8
  sleep 0.25
end


