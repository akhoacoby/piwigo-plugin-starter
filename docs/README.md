# Welcome to Piwigo Skills

Piwigo Skills is a companion kit for anyone who wants to build a plugin for Piwigo with the help of an AI assistant — whichever assistant you happen to like. Think of it as an experienced teammate sitting quietly beside your AI, making sure whatever it builds feels like a natural part of Piwigo rather than something bolted on from the outside.

This short guide explains what the folder is, why it exists, and how to get going.

> **Looking for the technical details?** The [main README](../README.md) is the developer-facing map of the repository — the full folder layout, how the pieces fit together, and the design decisions behind them.

## What this is

Piwigo has always been shaped by its community. Over the years, people have contributed some wonderful plugins that extend what the app can do, and that spirit of contribution is something we care about deeply.

At the same time, the way software gets built is changing. More and more developers now reach for an AI assistant to help write their plugins — and that's a great thing. But it comes with a catch: an AI that doesn't know Piwigo's habits and conventions will often produce something that *works*, yet doesn't quite *belong*. The buttons sit slightly off, the settings page looks foreign, the code follows patterns Piwigo simply doesn't use. The result feels like a guest rather than part of the family.

Piwigo Skills exists to close that gap. It gives your AI the context it needs — the structure, the conventions, the "how things are usually done here" — so the plugins it helps you create blend in seamlessly. And it does all of this without boxing you in: you still have all the room in the world to be creative and build something genuinely new.

## Who it's for

- **Developers** who want to build a Piwigo plugin and let an AI assistant do the heavy lifting.
- **Newcomers** to Piwigo who don't yet know its conventions and would rather not learn every one of them before starting.
- **Experienced contributors** who simply want their AI to stop reinventing patterns Piwigo already has.

You don't need to be an expert. If you can describe what you want your plugin to do, this kit helps your AI turn that into something that fits.

## Architecture

To provide you with a clearer understanding of the project, here are some crucial folder inside:

- **The conventions notes** — the ground rules. A capture of Piwigo's real constraints and the way things are done internally, so the AI starts from how Piwigo actually works rather than guessing.
- **Guidelines** — the background knowledge. Short notes on the "house style" for each area of a plugin, read before any work begins.
- **Workflows** — the recipes. Step-by-step playbooks for common tasks, so the AI follows a proven path instead of improvising. These describe the actual skills the assistant can carry out.
- **Reference** — the deep lookups. Detailed notes and concrete examples for the trickier corners, especially around making things look right across Piwigo's different themes.
- **A template and a skeleton** — the starting points. The template is a clean, empty plugin to build on so nobody starts from a blank page; the skeleton is a fuller, worked example that shows more of what's possible and how things fit together in practice.

Things like `.agents`, `.claude`, `.cursor`, `.github` is the model-based folder detected by the related model to be able to get access the skills tools. You can safely ignore them — they simply point different AI tools back to the same shared knowledge, which is how we make sure as many assistants as possible can use this kit.

## How to use it

Using Piwigo Skills is refreshingly simple:

1. **Keep this folder somewhere your AI can see it.** You can place it wherever you like, but we recommend keeping it right alongside your Piwigo app's code. That way your assistant can also glance at the real Piwigo source when it needs to, and you'll find it easier to follow along yourself.
2. **Open a session with your AI assistant and just start talking.** Describe the plugin you have in mind. There's no special command to learn — the assistant will pick up the knowledge in this folder on its own and work from it.
3. **Build, review, adjust.** Treat the AI as a capable teammate: let it draft, then guide it as you would any collaborator until the plugin is exactly what you wanted.

That's really all there is to it.

## Which AI assistants it works with

Piwigo Skills is written to be understood by essentially any coding-focused AI assistant on the market today. We've paid special attention to the most popular, flagship tools so they work as smoothly as possible:

**Claude Code · Cursor · GitHub Copilot · Qwen · Gemini / Antigravity · GLM**

If your tool of choice isn't on the list, don't worry — it will very likely work just fine. These are simply the ones we've tuned for first.

## A note on what to expect

We want to be honest with you. We don't have full access to the paid, top-tier version of every AI tool out there, so we can't promise that every assistant will perform equally well. Some may follow the guidance more faithfully than others, and results will vary a little from one tool to the next.

We see this kit as something that grows over time. The more people use it and tell us how it went, the better we can make it.

## We'd love to hear from you

If you build something with Piwigo Skills — whether it went beautifully or hit a few bumps — please share your experience. Your feedback is genuinely the fuel that helps us refine this for everyone who comes next.

Happy building, and welcome to the Piwigo community.

---

*Ready to go deeper? The [main README](../README.md) walks through the repository in full technical detail, and `AGENTS.md` is the file your AI assistant reads first.*
