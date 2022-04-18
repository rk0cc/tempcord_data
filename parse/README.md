# Tempcord data parser implementation

[![Pub version](https://img.shields.io/pub/v/tempcord_data_parser?style=flat-square)](https://pub.dev/packages/tempcord_data_parser)

This package aims to provide a standard of Tempcord data parser between [interface](https://pub.dev/packages/tempcord_data_interface) and Uint8List.

## Specification

A single Uint8List from `TempcordDataParser` contains at least 2 object: `Profile` and a list of `BodyTemperatureRecordNode`
with [LZMA](https://en.wikipedia.org/wiki/Lempel%E2%80%93Ziv%E2%80%93Markov_chain_algorithm) compressed.

There is the basic sample of how data contains in byte (for reference only):

```text
{"name":"Alice", "animal":"0"}
(Data divider)
temp,unit,recordedAt
36.9,℃,2020-03-12T12:32:20.324Z
35.4,℃,2020-03-13T12:22:43.982Z
37.1,℃,2020-04-23T09:12:39.571Z
```

## License

Apache 2.0