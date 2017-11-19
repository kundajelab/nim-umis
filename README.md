# nim-umis
A set of tools for efficiently processing UMIs
for WGS applications written in Nim (https://nim-lang.org/)

## Example usage
`deduplicate` writes sam-formatted output to `stdout`:
```
./deduplicate my_bam.bam |\
  sambamba view -S -f bam -o deduplicated.bam -t 4 /dev/stdin
```
