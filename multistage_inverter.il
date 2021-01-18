;/**********************************\
;> n-stage inverter schematic generation
;> Version: 1.0
;> Author: Rouhan Noor
;> Date: 15 June, 2020
;\**********************************/

;symbolId	= dbOpenCellViewByType( "practice" "" "symbol" "" 'r )
symbolId        = dbOpenCellViewByType("TB_CH_SLICE_BASE_45SPCLO_COPY" "nand_inv" "symbol" "" 'r)
;symbolId	= dbOpenCellViewByType("practice" "HC9T_INX1_SPO_R40" "symbol" "" 'r )
noOfStages = 101
;intId 		= schCreateInst( cv symbolId "I0" 1:1 "R0" )
;inst 		= car(cvId~>instances)
;dTerm 		= dbFindTermByName(inst~>master "D")
;pinCenter 	= dbTransformPoint(centerBox(pin~>bBox) inst~>transform)
;pinB		= car(dTerm~>pins~>fig~>bBox)
;pinCenter	= dbTransformPoint(centerBox(pinB) inst~>transform)
;inst2		= cadr(cv~>instances)
;dTerm2		= dbFindTermByName(inst2~>master "D")
;pinB2		= car(dTerm2~>pins~>fig~>bBox)
;pinCenter2	= dbTransformPoint(centerBox(pinB2) inst2~>transform)
;schCreateWire(cvId "draw" "full" list(pinCenter pinCenter2) 0.0625 0.0625 0.0)


procedure(

nStageInstances(noOfStages, symbolId)

cvID = geGetWindowCellView()

intId_prev = nil

for(i 0 noOfStages-1

	if(i > 0 then 	
	;;;;;;;;;;;;;;;;; generate instances/ cell ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		instName = strcat("I", sprintf(a "%d" i))		
		intId = schCreateInst(cvID symbolId instName (2*i + 1):0 "R0"  )
		
	;;;;;;;;;;;;;;;;; finding terminal of instances/cell ;;;;;;;;;;;;;;;;;;;
		dTermA_prev = dbFindTermByName(intId_prev~>master "A")
		dTermZ_prev = dbFindTermByName(intId_prev~>master "Z")

		dTermA = dbFindTermByName(intId~>master "A")
		dTermZ = dbFindTermByName(intId~>master "Z")
	
		dTermVDD_prev = dbFindTermByName(intId_prev~>master "VDD")
		dTermVSS_prev = dbFindTermByName(intId_prev~>master "VSS")

		dTermVDD = dbFindTermByName(intId~>master "VDD")
		dTermVSS = dbFindTermByName(intId~>master "VSS")	
	;;;;;;;;;;;;;;;;;;; finding pin from terminal ;;;;;;;;;;;;;;;;;;;;;;;;;
		pinA_prev = car(dTermA_prev~>pins~>fig~>bBox)
		pinZ_prev = car(dTermZ_prev~>pins~>fig~>bBox)

		pinA = car(dTermA~>pins~>fig~>bBox)
		pinZ = car(dTermZ~>pins~>fig~>bBox)

		pinVDD_prev = car(dTermVDD_prev~>pins~>fig~>bBox)
		pinVSS_prev = car(dTermVSS_prev~>pins~>fig~>bBox)

		pinVDD = car(dTermVDD~>pins~>fig~>bBox)
		pinVSS = car(dTermVSS~>pins~>fig~>bBox)
	;;;;;;;;;;;;;;;;; finding coordinates of pins ;;;;;;;;;;;;;;;;;;;;;;;;
		pinCenterA_prev	= dbTransformPoint(centerBox(pinA_prev) intId_prev~>transform)
		pinCenterZ_prev	= dbTransformPoint(centerBox(pinZ_prev) intId_prev~>transform)

		pinCenterA	= dbTransformPoint(centerBox(pinA) intId~>transform)
		pinCenterZ	= dbTransformPoint(centerBox(pinZ) intId~>transform)

		pinCenterVDD_prev = dbTransformPoint(centerBox(pinVDD_prev) intId_prev~>transform)
		pinCenterVSS_prev = dbTransformPoint(centerBox(pinVSS_prev) intId_prev~>transform)

		pinCenterVDD = dbTransformPoint(centerBox(pinVDD) intId~>transform)
		pinCenterVSS = dbTransformPoint(centerBox(pinVSS) intId~>transform)
	;;;;;;;;;;;;;;;; connecting pin with wire ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		schCreateWire(cvID "draw" "full" list(pinCenterZ_prev pinCenterA) 0.0625 0.0625 0.0)
		schCreateWire(cvID "draw" "full" list(pinCenterVDD_prev pinCenterVDD) 0.0625 0.0625 0.0)
		schCreateWire(cvID "draw" "full" list(pinCenterVSS_prev pinCenterVSS) 0.0625 0.0625 0.0)

		intId_prev = intId

		else 
			intId_prev = schCreateInst(cvID symbolId "I0" (2*i + 1):0 "R0")
		
		) 

	)

);procedure

;procedure(
	
;hystoryEffectChecking(nStages,symbolId)

;	nStagesInstances()	
	



;);procedure 
