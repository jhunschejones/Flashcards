# Flashcards

## Overview
While I was first working on studying for the JLPT in 2020, I began looking around at digital flashcard apps. Initially, I was unable to find any that met my specific needs so I decided to create my own. This application is built using Rails 6 and provides a user interface to create, store, curate, and study Japanese language learning flashcards, along with example audio clips.

After several iterations on the design and UX of this tool, I realized I had added enough features that [Anki](https://apps.ankiweb.net/) would be a better tool for my use-case. I have since stopped adding to this tool, but you are welcome to fork the repo and pick up where I left off, or just borrow an idea or two if you're looking to build your own flashcards app in Rails 🎉

## Selected features

My favorite part of working on this application was optimizing the study session user interface. My study sessions at the time were 30-60 minutes long, so even a small improvement had a big affect. To that end I improved mobile data usage with a [service worker](https://github.com/jhunschejones/Flashcards/blob/e0dcb26b4b5365500b0f14b568732dafdc2af4e5/public%2Fservice-worker.js), added a touch of JavaScript for [handling audio](https://github.com/jhunschejones/Flashcards/blob/e0dcb26b4b5365500b0f14b568732dafdc2af4e5/app/javascript/controllers/card_controller.js) on mobile Safari as well as Chrome, and did my best to hone the [front-end interactivity](https://github.com/jhunschejones/Flashcards/blob/e0dcb26b4b5365500b0f14b568732dafdc2af4e5/app/javascript/controllers/study_controller.js) for the study session experience.

## Screenshots

This app is optimized for both desktop and mobile use. Here are a few screenshots I grabbed from when I last had a version running in production:

All cards

![all cards screenshot](docs/screenshots/all%20cards.png)

All decks

![all decks screenshot](docs/screenshots/all%20decks.png)

Configure study session

![configure study session screenshot](docs/screenshots/configure%20study%20session.png)

Card front (in study session)

![card front screenshot](docs/screenshots/card%20front.png)

Card back (in study session)

![card back screenshot](docs/screenshots/card%20back.png)

Rate card difficulty (in study session)

![rate card difficulty screenshot](docs/screenshots/rate%20difficulty.png)
