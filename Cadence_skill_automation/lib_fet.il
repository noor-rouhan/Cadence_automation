procedure(
    create_fet(no_of_finger, finger_width)(
      
 ;       llx = .1
 ;       lly = .2
 ;       urx = .3
  ;      ury = .3
        cvID = geGetWindowCellView()
        dbCreateRect(cvID list("Cont" "drawing") list(.1:.2 .3:.4))

    )
);procedure 