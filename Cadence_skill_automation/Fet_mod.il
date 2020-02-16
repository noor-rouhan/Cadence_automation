;/**********************************\
;> Inverter generation SKILL Script
;> Version: 1.0
;> Author: Rouhan Noor
;> Data: 16.FEB.2020
;\**********************************/

;function for generating NMOS and PMOS
procedure(
        Fet(finger_no, per_finger_width, cell_type, Coord)

;required instances and parameters
obj = ddGetObj("mylib" "inverter_neural" "layout")
tcId = techGetTechFile(obj)
cvID = geGetWindowCellView()

contW = techGetSpacingRule(tcId "minWidth" "Cont")

nmos_width = per_finger_width
sep_nmos_cont = .30
min_poly_width = techGetSpacingRule(tcId "minWidth" list("Poly" "drawing"))
sep_poly_cont = .1
sep_oxide_cont = .06
sep_pimp_oxide = .18
sep_cont_cont = techGetSpacingRule(tcId "minSpacing" list("Cont" "drawing"))
sep_nwell_pimp = techGetSpacingRule(tcId "minSpacing" list("Nwell" "drawing"))
sep_poly_oxide_enclosure = .04

finger_width = (nmos_width-contW)/2

offset = (sep_pimp_oxide + sep_oxide_cont):(nmos_width - contW)/2+ sep_pimp_oxide
off_llx = xCoord(offset)
off_lly = yCoord(offset)

llx = xCoord(Coord) + off_llx 
lly = yCoord(Coord) + off_lly  

;creating oxide layer
oxide_llx = -sep_oxide_cont  + llx
oxide_lly = -finger_width + lly
oxide_ulx = contW*(finger_no + 1) + min_poly_width*finger_no + sep_poly_cont*finger_no*2 +sep_oxide_cont + llx
oxide_uly = contW + finger_width + lly
dbCreateRect(cvID list("Oxide" "drawing") list(oxide_llx:oxide_lly oxide_ulx:oxide_uly))

;creating pimp layer
pimp_llx = oxide_llx - sep_pimp_oxide
pimp_lly = oxide_lly - sep_pimp_oxide 
pimp_ulx = oxide_ulx + sep_pimp_oxide 
pimp_uly = oxide_uly + sep_pimp_oxide 
dbCreateRect(cvID list(cell_type "drawing") list(pimp_llx:pimp_lly pimp_ulx:pimp_uly))

if(cell_type == "Pimp" then
	nwell_llx = pimp_llx - .01
	nwell_lly = pimp_lly - .06
	nwell_ulx = pimp_ulx + .01
	nwell_uly = pimp_uly + .06
	dbCreateRect(cvID list("Nwell" "drawing") list(nwell_llx:nwell_lly nwell_ulx:nwell_uly))
)

n_contt =(nmos_width - 2*sep_oxide_cont + sep_cont_cont)/(contW + sep_cont_cont)
n_cont_floor = floor(n_contt)
;print(n_cont_floor)
sep_oxidee = (nmos_width - n_cont_floor*contW- (n_cont_floor - 1)*sep_cont_cont)/2 
;print(sep_oxidee)

coord_enclosure =   (nmos_width - contW)/2
cont_lly_prim = coord_enclosure - sep_oxidee
print(cont_lly_prim)
;print(coord_enclosure)

;creating contact layer and contact metal enclosure 
for(i 0 finger_no
	cont_llx = min_poly_width*i + sep_poly_cont*2*i + contW*i  + llx
	cont_lly = -cont_lly_prim + lly
	cont_ulx = cont_llx+ contW 
	cont_uly =-cont_lly_prim +  contW 
	
	metal_cont_llx = cont_llx 
	metal_cont_lly = oxide_lly 
	metal_cont_ulx = cont_llx + contW 
	metal_cont_uly = finger_width + contW+ lly

	;dbCreateRect(cvID list("Cont" "drawing") list(cont_llx:cont_lly cont_ulx:cont_uly))
	dbCreateRect(cvID list("Metal1" "drawing") list(metal_cont_llx:metal_cont_lly metal_cont_ulx:metal_cont_uly))
	for(i 0 n_cont_floor-1
		cont_lly = -cont_lly_prim + i*(contW + sep_cont_cont)+ lly 
		cont_uly = cont_lly + contW 
		dbCreateRect(cvID list("Cont" "drawing") list(cont_llx:cont_lly cont_ulx:cont_uly))

)
)

;creating poly layer
poly_lly = (finger_width+sep_pimp_oxide)*-1+lly - sep_poly_oxide_enclosure 
poly_uly = contW + finger_width + sep_pimp_oxide +lly + sep_poly_oxide_enclosure

for(i 0 finger_no-1

	poly_llx = contW*(i+1) + sep_poly_cont*(2*i + 1) + min_poly_width*i + llx
	poly_ulx = poly_llx + min_poly_width 
	dbCreateRect(cvID list("Poly" "drawing") list(poly_llx:poly_lly poly_ulx:poly_uly))
)

abs(oxide_llx- oxide_ulx)
);procedure 

;function for generating inverter
procedure(

	inverter(inv_finger_no, pmos_finger_width, nmos_finger_width, inv_coord)

offset = 0:0

off_llx = xCoord(offset)
off_lly = yCoord(offset)

inv_llx = xCoord(inv_coord) + off_llx 
inv_lly = yCoord(inv_coord) + off_lly

obj = ddGetObj("mylib" "inverter_neural" "layout")
tcId = techGetTechFile(obj)
cvID = geGetWindowCellView()

sep_pimp_oxide = .18
sep_pmos_nmos = .68
sep_cont_oxide = .06
min_metal_width = .12 
min_width_gate = .1
sep_poly_cont = .1
sep_cont_oxide = .06
min_metal_width = .12 
min_width_gate = .1
sep_poly_cont = .1 
;generating pmos 
oxide_length =  Fet(inv_finger_no ,pmos_finger_width , "Pimp", inv_llx:inv_lly)

;generating nmos
n_inv_lly = (inv_lly- sep_pmos_nmos - sep_pimp_oxide*2 - nmos_finger_width) 
Fet(inv_finger_no, nmos_finger_width, "Nimp", inv_llx:n_inv_lly) 

;routing inverter 
;shorting output metal
;shorting  pmos
m_rout_enc = sep_pimp_oxide + sep_cont_oxide + min_metal_width + sep_poly_cont*2 + min_width_gate
r_m_p_llx = inv_llx + m_rout_enc
r_m_p_lly = inv_lly - min_metal_width + .05 
r_m_p_ulx = inv_llx + oxide_length+ min_metal_width
r_m_p_uly = r_m_p_lly + min_metal_width
dbCreateRect(cvID list("Metal1" "drawing") list(r_m_p_llx:r_m_p_lly r_m_p_ulx:r_m_p_uly))
;shorting nmos
dbCreateRect(cvID list("Metal1" "drawing") list(r_m_p_llx:r_m_p_lly-sep_pmos_nmos+.02 r_m_p_ulx:r_m_p_uly-sep_pmos_nmos+.02))
;;;
;sorting source
sort_vdd_llx = inv_llx + sep_pimp_oxide + sep_cont_oxide
sort_vdd_lly = inv_lly + sep_pimp_oxide*2 + pmos_finger_width - .05 
sort_vdd_ulx = sort_vdd_llx + oxide_length-sep_cont_oxide*2 
sort_vdd_uly = sort_vdd_lly + min_metal_width 
dbCreateRect(cvID list("Metal1" "drawing") list(sort_vdd_llx:sort_vdd_lly sort_vdd_ulx:sort_vdd_uly)) 
;sorting ground
sort_vss_llx = sort_vdd_llx
sort_vss_lly = inv_lly - sep_pmos_nmos - sep_pimp_oxide*2 - nmos_finger_width - .07 
sort_vss_ulx = sort_vdd_ulx
sort_vss_uly = sort_vss_lly + min_metal_width 
dbCreateRect(cvID list("Metal1" "drawing") list(sort_vss_llx:sort_vss_lly sort_vss_ulx:sort_vss_uly))

;shorting nmos pmos output metal
dbCreateRect(cvID list("Metal1" "drawing") list((r_m_p_ulx - min_metal_width):(inv_lly - sep_pmos_nmos) r_m_p_ulx:inv_lly ))
;sorting all gate and create via
viaDefId = techFindViaDefByName(tcId "M1_POv")
viaParams = list(list("cutRows" 1) list("cutColumns" 1))

gate_lly = inv_lly 
gate_uly = inv_lly - sep_pmos_nmos

for(i 0 inv_finger_no-1

	gate_llx = .12*(i+1) + sep_poly_cont*(2*i + 1) + min_poly_width*i +inv_llx+ .24
 	gate_ulx = gate_llx + min_width_gate
        dbCreateRect(cvID list("Poly" "drawing") list(gate_llx:gate_lly gate_ulx:gate_uly))
	dbCreateVia(cvID viaDefId list( gate_llx (inv_lly-sep_pmos_nmos/2)) "R0" viaParams)
)

;sorting all via 
via_srt_llx = inv_llx+sep_pimp_oxide + sep_cont_oxide +.12 
via_srt_lly = inv_lly - sep_pmos_nmos/2 - .12
via_srt_ulx = inv_llx + .12*inv_finger_no + sep_poly_cont*(2*inv_finger_no + 1)+ min_poly_width*(inv_finger_no-1)
via_srt_uly = via_srt_lly + .24
dbCreateRect(cvID list("Metal1" "drawing") list(via_srt_llx:via_srt_lly via_srt_ulx:via_srt_uly))

;sorting
if(mod(inv_finger_no,2)==0 then
  srs_vdd_connect = inv_finger_no+1
  
else 
  srs_vdd_connect = inv_finger_no
) 
for(i 0 srs_vdd_connect
     
          metal_vdd_llx = inv_llx + sep_pimp_oxide + sep_cont_oxide + .12*i + .1*2*i + min_width_gate*i 
          metal_vdd_lly =inv_lly + sep_pimp_oxide + pmos_finger_width 
          metal_vdd_ulx = metal_vdd_llx + .12
          metal_vdd_uly = metal_vdd_lly + sep_pimp_oxide
	  metal_vss_uly = inv_lly - nmos_finger_width - sep_pimp_oxide*2 - sep_pmos_nmos  
	  metal_vss_lly = metal_vss_uly + sep_pimp_oxide

;connecting output metal 	  
		if((mod(i,2) == 0) then 
			dbCreateRect(cvID list("Metal1" "drawing") list(metal_vdd_llx:metal_vdd_lly metal_vdd_ulx:metal_vdd_uly))
			dbCreateRect(cvID list("Metal1" "drawing") list(metal_vdd_llx:metal_vss_lly metal_vdd_ulx:metal_vss_uly))
		)
		if((mod(i,2) == 1) then
			if((metal_vdd_llx < (inv_llx+oxide_length+sep_pimp_oxide*2)) then 
			dbCreateRect(cvID list("Metal1" "drawing") list(metal_vdd_llx:inv_lly metal_vdd_ulx:(inv_lly+sep_pimp_oxide)))
			dbCreateRect(cvID list("Metal1" "drawing") list(metal_vdd_llx:inv_lly-sep_pmos_nmos metal_vdd_ulx:inv_lly-sep_pimp_oxide-sep_pmos_nmos-.01))
       		))
		
               
)
);procedure




































