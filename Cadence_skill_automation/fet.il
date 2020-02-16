; Author : Grabbed from Cadence forum 

;
;  This pcell demonstrates the use of sub-rectangles and offset subpaths
;  in the multipart path transistor implementation.  The name of the master
;  view is:
;
;     pcells step8 layout
;
;  This pcell accepts these parameters:
;
;     width       Width of the transistor's active area (note: this is a
;                 distance measured in the Y-direction).
;                 (float, default = 3.0)
;
;     length      Length of the transistor's active area (note: this is a
;                 distance measured in the X-direction).
;                 (float, default = 0.6)
;
;     polyLayer   Name of the poly layer.
;                 (string, default = "poly")
;
;     diffLayer   Name of the diffusion layer.
;                 (string, default = "pdiff")
;
;     contLayer   Name of the contact layer.
;                 (string, default = "cont")
;
;     metalLayer  Name of the metal layer.
;                 (string, default = "metal1")
;
;     drainName   Name of the drain connection.
;                 (string, default = "D")
;
;     gateName    Name of the gate connection.
;                 (string, default = "G")
;
;     sourceName  Name of the source connection.
;                 (string, default = "S")
;
;     sourceContact Whether source contacts should be included
;                 (boolean, default = t)
;
;     drainContact Whether drain contacts should be included
;                 (boolean, default = t)
;
pcDefinePCell(
   ;  Identify the target cellview.
   list(ddGetObj("pcells") "step8" "layout")

   ;  Define formal parameter name-value pairs.
   (
      (width 3.0)
      (length 0.6)
      (polyLayer "poly")
      (diffLayer "pdiff")
      (contLayer "cont")
      (metalLayer "metal1")
      (drainName "D")
      (gateName "G")
      (sourceName "S")
      (sourceContact t)
      (drainContact t)
   )

   ;  Define the contents of this cellview.
   let((tfId polyExtend contWidth polyContSep diffContEnclose
        metalContEnclose diffPolyEnclose pinEndOffset polySep transObj grid
	polyDiffSep sdWidth)

      ; convert to proper booleans
      sourceContact=(sourceContact==t || sourceContact=="TRUE")
      drainContact=(drainContact==t || drainContact=="TRUE")

      ;  Get the technology information for this cell.
      tfId = techGetTechFile(ddGetObj("pcells"))

      ;  Get the minimum extension of poly beyond diffusion.
      polyExtend = techGetSpacingRule(tfId "minExtension" polyLayer)

      ;  Get the minimum contact width.
      contWidth = techGetSpacingRule(tfId "minWidth" contLayer)

      ;  Get the gate spacing
      polySep = techGetSpacingRule(tfId "minSpacing" polyLayer)

      ;  Get the minimum poly to contact spacing.
      polyContSep = techGetSpacingRule(tfId "minSpacing" polyLayer contLayer)

      ;  Get the minimum poly to diffusion spacing.
      polyDiffSep = techGetSpacingRule(tfId "minSpacing" polyLayer diffLayer)

      ;  Get the minimum diffusion enclosure of contact.
      diffContEnclose =
	  techGetOrderedSpacingRule(tfId "minEnclosure" diffLayer contLayer)

      ;  Get the minimum diffusion enclosure of poly (used when metal contacts
      ;  not included)
      diffPolyEnclose =
	  techGetOrderedSpacingRule(tfId "minEnclosure" diffLayer polyLayer)

      ;  Get the minimum metal enclosure of contact.
      metalContEnclose =
      techGetOrderedSpacingRule(tfId "minEnclosure" metalLayer contLayer)

      ;  pin end offset
      pinEndOffset = -(polyExtend + diffContEnclose - metalContEnclose)

      ;  source/drain width
      sdWidth = contWidth+polyContSep+diffContEnclose

      ;  Get the minimum resolution for this process.
      grid = techGetMfgGridResolution(tfId)

      ;------------------------------------------------------------------
      ; Create the gate and diffusion regions.
      ;------------------------------------------------------------------
      transObj = rodCreatePath(
         ?layer list(polyLayer "drawing")
         ?endType     "variable"
	 ?width length
         ?pts list(0.0:0.0 0.0:width)
         ?beginExt polyExtend
         ?endExt  polyExtend
         ;  Define the diffusion region - just under the gate
         ?encSubPath
	 setof(arg
	     list(
		list(
		   ?layer list(diffLayer "drawing")
		   ?enclosure 0.0
		   ?beginOffset -polyExtend
		   ?endOffset -polyExtend
		)
	     )
	     arg
	 )
         ?offsetSubPath
	 setof(arg
	     list(
		;  Define the drain metal stripe.
		when(drainContact
		    list(
		       ?layer list(metalLayer "drawing")
		       ?pin t
		       ?termName drainName
		       ?justification "left"
		       ?width contWidth + 2.0*metalContEnclose
		       ?sep polyContSep - metalContEnclose
		       ?beginOffset pinEndOffset
		       ?endOffset pinEndOffset
		    )
		)
		;  Define the source metal stripe.
		when(sourceContact
		    list(
		       ?layer list(metalLayer "drawing")
		       ?pin t
		       ?termName sourceName
		       ?justification "right"
		       ?width contWidth + 2.0*metalContEnclose
		       ?sep polyContSep - metalContEnclose
		       ?beginOffset pinEndOffset
		       ?endOffset pinEndOffset
		    )
		)
		;  Define the diffusion source area
		list(
		    ?layer list(diffLayer "drawing")
		    ; width depends on whether source contact included or not
		    ?width if(sourceContact sdWidth diffPolyEnclose)
		    ?justification "right"
		    ?beginOffset -polyExtend
		    ?endOffset -polyExtend
		)
		;  Define the diffusion drain area
		list(
		    ?layer list(diffLayer "drawing")
		    ; width depends on whether drain contact included or not
		    ?width if(drainContact sdWidth diffPolyEnclose)
		    ?justification "left"
		    ?beginOffset -polyExtend
		    ?endOffset -polyExtend
		)
		;  Define the drain diffusion pin. For abut reasons the pin is
		;  the same height that the metal pin is
		;  NOTE - if the difference between diffPolyEnclose and polySep
		;  is greater than the minimum gate length, then when abutted
		;  the drain pin from one transistor can short out the
		;  other transistor. This could be dealt with if necessary by
		;  making the code a bit smarter
		list(
		   ?layer list(diffLayer "pin")
		   ?pin t
		   ?termName drainName
		   ?justification "left"
		   ; width adjusts to ensure that the diffusion pins will touch
		   ; when the devices abut
		   ?width if(drainContact sdWidth diffPolyEnclose)
		   ?beginOffset pinEndOffset
		   ?endOffset pinEndOffset
		)
		;  Define the source diffusion pin. For abut reasons the pin is
		;  the same height that the metal pin is
		list(
		   ?layer list(diffLayer "pin")
		   ?pin t
		   ?termName sourceName
		   ?justification "right"
		   ?width if(sourceContact sdWidth diffPolyEnclose)
		   ?beginOffset pinEndOffset
		   ?endOffset pinEndOffset
		)
	     )
	     arg
	 )
         ?subRect
	 setof(arg
	     list(
		;  Define the drain contact array.
		when(drainContact
		    list(
		       ?layer       list(contLayer "drawing")
		       ?justification "left"
		       ?sep polyContSep
		       ?beginOffset -(polyExtend + diffContEnclose)
		       ?endOffset   -(polyExtend + diffContEnclose)
		    )
		)
		;  Define the source contact array.
		when(sourceContact
		    list(
		       ?layer       list(contLayer "drawing")
		       ?justification "right"
		       ?sep polyContSep
		       ?beginOffset -(polyExtend + diffContEnclose)
		       ?endOffset   -(polyExtend + diffContEnclose)
		    )
		)
		;  Define the gate pins.
		list(
		   ?layer       list(polyLayer "pin")
		   ?pin t
		   ?termName gateName
		   ?width length
		   ?length grid
		   ?space width - 2*grid
		)
	     )
	     arg
	 )
      )
      rodCreateRect(
	?layer contLayer

	?width 2.0
	?length 3.0
	)
;      rodUnNameShape(transObj)

      ;------------------------------------------------------------------
      ; Dimensions for auto-abutment 
      ; This is fairly simplistic, and in the case of different sized
      ; devices it can end up with the spacing between gates not quite
      ; as tight as possible in some cases. However, it demonstrates
      ; the principle.
      ; These dimensions are used in the abut function
      ;------------------------------------------------------------------
      pcCellView~>sameWidthDist=-diffPolyEnclose
      pcCellView~>diffWidthDist=polyDiffSep-diffPolyEnclose

      ;------------------------------------------------------------------
      ; Prevent overlap markers
      ;------------------------------------------------------------------
      pcCellView~>lxBlockOverlapCheck=t

      ;------------------------------------------------------------------
      ; Add auto-abutment properties
      ;------------------------------------------------------------------
      foreach(pin dbFindTermByName(pcCellView "S")~>pins
	  pin~>fig~>abutFunction="abAbutFunction"
	  pin~>fig~>abutAccessDir='("right")
      )
      foreach(pin dbFindTermByName(pcCellView "D")~>pins
	  pin~>fig~>abutFunction="abAbutFunction"
	  pin~>fig~>abutAccessDir='("left")
      )

   )
)