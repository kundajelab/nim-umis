import os
import osproc
import streams
import docopt
import gzutil
import strutils as S

when(isMainModule):
  let doc = """
extract: extract UMIs from sequences to read name suffixes

Usage:
  deduplicate <fq1in> <fq2in> <fq1out> <fq2out>
"""
  let version = "extract 0.0.1"
  let args = docopt(doc, version = version)

  let fq1inf = $args["<fq1in>"]
  let fq2inf = $args["<fq2in>"]
  let fq1outf = $args["<fq1out>"]
  let fq2outf = $args["<fq2out>"]

  let fq1in = openGzRead(fq1inf)
  let fq2in = openGzRead(fq2inf)
  let fq1out = openGzWrite(fq1outf)
  let fq2out = openGzWrite(fq2outf)

  const umiLength = 6
  const removeAfterUmi = 11

  while not atEnd(fq1in) and not atEnd(fq2in):

    let r1id = readLine(fq1in)
    let r2id = readLine(fq2in)

    if len(r1id) == 0 or len(r2id) == 0:
      continue

    let r1seq = readLine(fq1in)
    let r2seq = readLine(fq2in)

    let r1p = readLine(fq1in)
    let r2p = readLine(fq2in)

    let r1qu = readLine(fq1in)
    let r2qu = readLine(fq2in)

    let r1umi = r1seq[0 .. umiLength]
    let r2umi = r2seq[0 .. umiLength]
    let umisuff = "_" & r1umi & r2umi

    let r1idt = S.splitWhitespace(r1id)[0] & umisuff
    let r2idt = S.splitWhitespace(r2id)[0] & umisuff

    let r1seqt = r1seq[umiLength + removeAfterUmi .. ^1]
    let r2seqt = r2seq[umiLength + removeAfterUmi .. ^1]

    let r1qut = r1qu[umiLength + removeAfterUmi .. ^1]
    let r2qut = r2qu[umiLength + removeAfterUmi .. ^1]

    fq1out.writeLine(r1idt)
    fq1out.writeLine(r1seqt)
    fq1out.writeLine(r1p)
    fq1out.writeLine(r1qut)

    fq2out.writeLine(r2idt)
    fq2out.writeLine(r2seqt)
    fq2out.writeLine(r2p)
    fq2out.writeLine(r2qut)

  fq1in.close()
  fq2in.close()
  fq1out.close()
  fq2out.close()
  stderr.writeLine("Done!")
