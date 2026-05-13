# AI Pipeline Documentation

## The Consensus Mechanism
SnapSolve doesn't rely on a single model. It uses a **Consensus Engine** to ensure reliability.

### Supported Models
- **Gemini 1.5 Pro**: Primary model for multimodal (image) analysis.
- **Llama 3 (via Groq)**: High-speed semantic reasoning.
- **Claude 3.5 Sonnet (via OpenRouter)**: Advanced code and system diagnosis.

### Pipeline Steps
1. **Preprocessing**: Image is resized and optimized for token efficiency.
2. **Local Heuristics**: App-side logic detects common app patterns (e.g., Payment UIs) to prime the AI.
3. **Parallel Querying**:
   - Model A analyzes visual layout.
   - Model B analyzes OCR text.
   - Model C cross-references with a troubleshooting knowledge base.
4. **Verification**: If models disagree on severity or root cause, the engine triggers a "Tie-breaker" prompt or flags the result as low-confidence.
5. **Output Formatting**: Result is parsed into a strict JSON schema for UI consumption.

## Prompt Engineering
SnapSolve uses "Master Expert Reasoning" prompts which force the models to:
- Act as Senior Lead Engineers.
- Provide surgical fixes rather than generic advice.
- Explicitly list "What Not To Do".
