pachinko
========

Pachinko is a Ruby monkeypatch manager tool attempting to control the unpredictable and difficult-to-troubleshoot regressions possible when monkeypatches run amok and unchecked in a medium to large Ruby codebase.

If you have a lot of files in your lib directory which backport features, fix long-fixed bugs or apply other such behavior changes which are never being followed up on later on, via monkeypatching... This gem may be for you!

The idea is, the Pachinko patch itself checks to see whether it even needs to be applied to your stack to begin with, every time it runs. In order to make that happen you sometimes have to come up with a clever on-the-fly "test for relevancy" but once you succeed in doing that, your patch will auto-expire and/or let you know when it's no longer relevant. Your test for relevancy should ideally check actual behavior and not just the presence/absence of a method or version number. That way it can PROVE it is still relevant (or not).

Pachinko will let you know 3 things right in the console when your stack loads:

1) If the patch did apply successfully
2) It will warn you if the patch was run but didn't seem to change any behavior (it reruns the relevancy check after the patch is run to make sure the output changed)
3) It will warn you when the patch seems to no longer be relevant (but still applies it)

There are a few examples in the 'examples' directory, including some things like automatically-expiring backported features from versions of Rails ostensibly after the version you are stuck on, bugfixes that are not yet on your Rails version, etc.

Once you write your Pachinko patch, just drop it in your lib or anywhere you automatically require stuff. Or manually require it from your initialization or application code.

I've tried to make this gem agnostic to the type of Ruby project you have, but typically this will end up being most useful on monolithic Rails apps.

If this gem does help you,

1) Totally awesome, let me know! peter@marreck.com
2) It's probably a hint that you should consider breaking up your app code somehow, architecturally. ;)

I'm too busy to look up proper Markdown formatting right now, I'll clean this up later.

Oh, one last thing, I LOVE PULL REQUESTS. ;)

Happy monkeypatchery,
-Peter
