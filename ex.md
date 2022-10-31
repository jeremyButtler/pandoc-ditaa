```ditaa
[-S -W -E --scale 0.8]

   +---------+ +----------------------+ +--------------------------+
   |Reads{io}+ |Trimmed references{io}| |Full length references{io}|
   +---+-----+ +---------+------------+ +------------+-------------+
       |                 |                           |
       +-----------------+---------------------------+
      +-=-=-=-=-=-=+     |
+-----+Filter reads+-----+
|     +-=-=-=-=-=-=+
| +-----------------------------------------------+
+-+Map reads to trimmed  Remove low    Score reads+-+
  |     references      quality reads         cFF3| |
  +-----------------------------------------------+ |
                    +-=-=-=-=-+                     |
+-------------------+Bin reads+---------------------+
|                   +-=-=-=-=-+
| +--------------------------------------------------------------------------+
+-+Remap reads to  Trim alignments with  Bin reads by reference  Remove small+-+
  |  references       highest mapq           with best mapq    c4C8  bins    | |
  +--------------------------------------------------------------------------+ |
                        +-=-=-=-=-=+                                           |
+-----------------------+Clustering+-------------------------------------------+
|                       +-=-=-=-=-=+    
| +------------------------------------------------+
+-+Subsample  Cluster    Build    Remove similar   +-+
  |  reads     reads  consensuses  consensuses c379| |
  +------------------------------------------------+ |
                   +-=-=-=-=-=-=-=-=-=-=-+           |
+------------------+Build final consensus+-----------+
|                  +-=-=-=-=-=-=-=-=-=-=-+
| +---------------------------------------------------------------------------------+
+-+Score reads with full  Subsample & build  Trim consensus using  Compare & remove |
  |  length references        consensus  c405 trimmed references  similar consensues|
  +---------------------------------------------------------------------------------+

[
  Steps used in the co-infection pipeline to detect co-infections.
]{ #fig:pipeline }
```

