import cv2
import numpy as np

cap = cv2.VideoCapture(0)

while True:
    ret, frame = cap.read()
    if not ret:
        break
    
    h, w = frame.shape[:2]
    cx, cy = w // 2, h // 2
    r = min(w, h) // 3
    
    # Draw circle guide
    display = frame.copy()
    cv2.circle(display, (cx, cy), r, (0, 255, 0), 2)
    cv2.putText(display, "Fit your face in the circle, press SPACE to capture", 
                (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255,255,255), 2)
    cv2.imshow("Take Photo", display)
    
    key = cv2.waitKey(1)
    if key == 32:  # space
        # GrabCut background removal
        mask_gc = np.zeros(frame.shape[:2], np.uint8)
        bgd_model = np.zeros((1, 65), np.float64)
        fgd_model = np.zeros((1, 65), np.float64)
        
        rect = (cx-r, cy-r, r*2, r*2)
        cv2.grabCut(frame, mask_gc, rect, bgd_model, fgd_model, 5, cv2.GC_INIT_WITH_RECT)
        
        mask2 = np.where((mask_gc == 2) | (mask_gc == 0), 0, 1).astype('uint8')
        fg = frame * mask2[:, :, np.newaxis]
        
        # Apply grabcut mask to alpha channel properly
        result = cv2.cvtColor(frame, cv2.COLOR_BGR2BGRA)
        
        # Combine grabcut mask with circle mask
        circle_mask = np.zeros((h, w), dtype=np.uint8)
        cv2.circle(circle_mask, (cx, cy), r, 255, -1)
        
        combined_mask = cv2.bitwise_and(mask2 * 255, circle_mask)
        result[:, :, 3] = combined_mask
        
        # Crop to circle bounding box
        cropped = result[cy-r:cy+r, cx-r:cx+r]
        cropped = cv2.resize(cropped, (128, 128))
        
        cv2.imwrite("character.png", cropped)
        break
    
cap.release()
cv2.destroyAllWindows()
