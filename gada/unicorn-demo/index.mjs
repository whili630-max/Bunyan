import OpenAI from "openai";
const client = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
const res = await client.responses.create({
  model: "gpt-5",
  input: "Write a one-sentence bedtime story about a unicorn."
});
console.log(res.output_text);
