import docopt
import hts as hts
import strutils as S
import sets

type mateInfo = tuple[st: string, pos: int32]

when(isMainModule):
  let doc = """
deduplicate: remove duplicates from a bam file using UMIs

Usage:
  deduplicate <bam>
"""
  let version = "deduplicate 0.0.1"
  let args = docopt(doc, version = version)
  let bamfile = cstring($args["<bam>"])
  var bam:Bam
  open(bam, bamfile, threads=4, index=true)

  var
    cur_start = 0
    todrop = initSet[mateInfo]()
    curPosMates = initSet[mateInfo]()
    canRelease = initSet[mateInfo]()

    numRecords = 0
    numDuplicates = 0

  for record in bam:

    numRecords += 1
    var shouldWrite = true

    let qn = S.split(record.qname, "_")
    assert(len(qn) == 2)  # `QNAME:WITH:PARTS_UMI`

    if record.start != cur_start:
      curPosMates.clear()
      todrop.excl(canRelease)
      canRelease.clear()
      cur_start = record.start

    if record.start < record.matepos:
      # This is the first record of the pair

      var minfo: mateInfo  # (umi_seq, mate_position)
      minfo = (st: qn[1], pos: record.matepos)
      var tinfo: mateInfo  # (read_name, mate_position)
      tinfo = (st: qn[0], pos: record.matepos)

      if curPosMates.containsOrIncl(minfo):  # returns true if key was already present
        todrop.incl(tinfo)
        shouldWrite = false

    else:
      # This is the second record of the pair

      var tinfo: mateInfo  # (read_name, start_position)
      tinfo = (st: qn[0], pos: int32(record.start))

      if todrop.contains(tinfo):
        canRelease.incl(tinfo)
        shouldWrite = false

    if not shouldWrite:
      numDuplicates += 1
      echo "found duplicate!"


  echo "Finished. Num records: ", numRecords, ", num duplicates: ", numDuplicates
