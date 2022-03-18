#IMPORTING LIBRARIES
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input
from tensorflow.keras.preprocessing.image import load_img, img_to_array
from tensorflow.keras.models import load_model
from tensorflow.keras.optimizers import Adam
import numpy as np
import os


#Directories - NEED TO BE CHANGED BASED ON WHERE THE IMGS AND THE WEIGHTS ARE STORED
#Most important paths are - SCANNED_IMG & WHOLE_MODEL
RUNS_DIR = "/Users/sankeerthana/Documents/NTU/YEAR_3/CZ3002_ASE/Lab/runs"
TEST_TRIAL_IMGS = "/Users/sankeerthana/Documents/NTU/YEAR_3/CZ3002_ASE/Lab/test_trial_imgs"
SCANNED_IMG = os.path.join(TEST_TRIAL_IMGS,"scanned_flower_7.jpeg")
MOBILENETV2_DIR = os.path.join(RUNS_DIR,"mobilenetv2")
ARCHITECTURE = os.path.join(MOBILENETV2_DIR, "architecture.json")
WHOLE_MODEL = os.path.join(MOBILENETV2_DIR,"transfer_learning_try3.h5")
BEST_WTS = os.path.join(MOBILENETV2_DIR, "weights-improvement-07-0.96..h5")


def run():
    model = load_model(WHOLE_MODEL)

    #It is impt to compile the loaded model so that predictions can be made using the Keras 
    #backend correctly
    optimizer = Adam(learning_rate = 0.0001)
    model.compile(loss='sparse_categorical_crossentropy', optimizer=optimizer, metrics=['sparse_categorical_accuracy'])

    img_arr = image_preprocessing(SCANNED_IMG)

    #making predictions
    predictions = model.predict(img_arr)
    predicted_class_indices = np.argmax(predictions, axis=1)

    classes = {'bluebell': 0, 'buttercup': 1, 'colts_foot': 2, 'cowslip': 3, 'crocus': 4, 'daffodil': 5, 'daisy': 6, 'dandelion': 7, 'fritillary': 8, 'iris': 9, 'lily_valley': 10, 'pansy': 11, 'snowdrop': 12, 'sunflower': 13, 'tigerlilly': 14, 'tulip': 15, 'windflower': 16}
    #evaluate(model,img_arr)
    
    classes_keys = list(classes.keys())
    label = classes_keys[predicted_class_indices[0]]

    return label

def evaluate(model, img_arr):
    score = model.evaluate(img_arr)
    print(f'Test loss: {score[0]} / Test accuracy: {score[1]}')

def image_preprocessing(path_img):
    #loading the image - parameter is a path to the img
    image = load_img(path_img, target_size=(640,480))

    #preprocessing the image
    img_arr = img_to_array(image)
    img_arr = img_arr.reshape((1, img_arr.shape[0], img_arr.shape[1], img_arr.shape[2]))
    img_arr = preprocess_input(img_arr)

    return img_arr

#label = run("best")
#print("Label:", label)






