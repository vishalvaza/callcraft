"""
LLM Service - Abstracts LLM provider (Ollama, vLLM, OpenAI, etc.)
"""
import httpx
from typing import Dict, Optional
import logging

from app.core.config import settings

logger = logging.getLogger(__name__)


class LLMService:
    """
    LLM service for inference
    Provider-agnostic interface that can work with Ollama, vLLM, or OpenAI
    """

    def __init__(self, base_url: Optional[str] = None, model: Optional[str] = None):
        self.base_url = base_url or settings.OLLAMA_BASE_URL
        self.model = model or settings.OLLAMA_MODEL
        self.temperature = settings.LLM_TEMPERATURE
        self.max_tokens = settings.LLM_MAX_TOKENS

    async def generate(
        self,
        prompt: str,
        system_prompt: Optional[str] = None,
        temperature: Optional[float] = None,
        max_tokens: Optional[int] = None,
    ) -> str:
        """
        Generate text using the LLM

        Args:
            prompt: User prompt/input
            system_prompt: Optional system prompt
            temperature: Optional temperature override
            max_tokens: Optional max tokens override

        Returns:
            Generated text
        """
        temp = temperature if temperature is not None else self.temperature
        max_tok = max_tokens if max_tokens is not None else self.max_tokens

        # Build messages
        messages = []
        if system_prompt:
            messages.append({"role": "system", "content": system_prompt})
        messages.append({"role": "user", "content": prompt})

        # Call Ollama API
        try:
            async with httpx.AsyncClient(timeout=120.0) as client:
                response = await client.post(
                    f"{self.base_url}/api/chat",
                    json={
                        "model": self.model,
                        "messages": messages,
                        "stream": False,
                        "options": {
                            "temperature": temp,
                            "num_predict": max_tok,
                        },
                    },
                )
                response.raise_for_status()
                data = response.json()
                return data["message"]["content"]

        except httpx.HTTPError as e:
            logger.error(f"LLM API error: {e}")
            raise Exception(f"LLM service unavailable: {str(e)}")
        except KeyError as e:
            logger.error(f"Unexpected LLM response format: {e}")
            raise Exception("Invalid LLM response format")

    async def generate_json(
        self,
        prompt: str,
        system_prompt: Optional[str] = None,
        temperature: Optional[float] = None,
    ) -> Dict:
        """
        Generate JSON-structured response

        Args:
            prompt: User prompt requesting JSON output
            system_prompt: Optional system prompt
            temperature: Optional temperature override

        Returns:
            Parsed JSON dict
        """
        import json

        # Add JSON formatting instruction to prompt
        json_prompt = f"{prompt}\n\nProvide your response in valid JSON format only, without any additional text or markdown."

        response_text = await self.generate(
            prompt=json_prompt,
            system_prompt=system_prompt,
            temperature=temperature,
        )

        # Try to extract JSON from response (handle markdown code blocks)
        try:
            # Remove markdown code blocks if present
            if "```json" in response_text:
                start = response_text.find("```json") + 7
                end = response_text.find("```", start)
                response_text = response_text[start:end].strip()
            elif "```" in response_text:
                start = response_text.find("```") + 3
                end = response_text.find("```", start)
                response_text = response_text[start:end].strip()

            return json.loads(response_text)
        except json.JSONDecodeError as e:
            logger.error(f"Failed to parse JSON from LLM: {e}")
            logger.error(f"Response text: {response_text}")
            raise Exception("LLM did not return valid JSON")

    async def health_check(self) -> bool:
        """Check if LLM service is available"""
        try:
            async with httpx.AsyncClient(timeout=5.0) as client:
                response = await client.get(f"{self.base_url}/api/tags")
                return response.status_code == 200
        except:
            return False


# Global instance
llm_service = LLMService()
