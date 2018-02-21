To run tests:

Web Face
bundle exec cucumber faces/web/tests -r faces/web/tests

Core
bundle exec cucumber core/tests -r core/tests

Oddities
- in the testing framework avoid test-evaluating (eg. page.evaluate_script(...)) any JS that references the PhaserJS "game" object
--- it may lock up. I think what's happening is that it tries to evaluate the game object, which references another object,
--- which references back to the game, but that causes an infinite loop.