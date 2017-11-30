# Upgrading

This document intends to document manual interactions needed for certain
upgrade paths.

## 0.23.1

- All `RATE_LIMITING_*` settings were renamed to `HIVE_RATE_LIMITING_*`
  respectively.

## 0.8.0

When migrating to v0.8.0 with *existing* data, you have to trigger
recalculation of scheduled player updates. Otherwise, no new updates will be
scheduled.

To do this, open a Padrino console, and enter the following:

```
Player.each { |player| Resque.enqueue(Observatory::ClassifyPlayerUpdateFrequency, player.id) }
```

It is advised to not have the scheduler running until all those jobs have
finished processing.
