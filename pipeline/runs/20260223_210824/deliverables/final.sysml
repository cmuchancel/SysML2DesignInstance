package RequirementsOnly {
  requirement RQ_001 {
    text = "# Natural-language brief (echoed twice per Sysmlgeneration guidance)
Design a 5V rechargeable LED flasher that blinks at 10 Hz ±5%, keeps LED current between 8 mA and 20 mA, runs at least 8 hours per charge, and uses sourceable off-the-shelf parts.

-- repeat --
Design a 5V rechargeable LED flasher that blinks at 10 Hz ±5%, keeps LED current between 8 mA and 20 mA, runs at least 8 hours per charge, and uses sourceable off-the-shelf parts.

# Instructions to the model (keep in prompt for refine_sysml.py)
- Emit the minimal SysMLv2 that satisfies the brief.
- Avoid redundant packages/properties; be concise.
- Conform to SysIDE; model must pass `syside check`.
- If uncertain, make the best assumption and note it in a comment.";
  }
}