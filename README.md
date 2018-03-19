# monitoring_tivoli

Installs base OS monitoring agent for the detected platform.

## Supported Platforms

### Tested And Validated On
- Redhat 7.2,7.3

## Usage

To use, add the following to your run list

### monitoring_tivoli::default

Include `monitoring_tivoli` in your run_list.

```json
{
  "run_list": [
    "recipe[monitoring_tivoli::default]"
  ]
}
```


## Testing

TODO: Write how you plan to test this cookbook.
