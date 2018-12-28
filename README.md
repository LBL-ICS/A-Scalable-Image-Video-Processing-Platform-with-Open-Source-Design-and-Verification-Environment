# A-Scalable-Image-Video-Processing-Platform-with-Open-Source-Design-and-Verification-Environment
This project presents an image/video processing platform, enabling to capture frames of images by interfacing a low-cost OV7670 camera and in real time display both the original images and the results of processed images on a VGA-interfaced monitor. Specifically we presents our framework able to simultaneously display up to four 320x240 images in a 640x480 window, capable of showing the in-process images, the final results of the images, as well as the original images through the VGA interface. As a case study, we design a simple color to binary converter with two submodules - color to grayscale converter and then grayscale to binary converter. We demonstrate the validity of showing all the original color images captured from the OV7670 camera, the inter-process grayscale images, and the final binary images in different regions via the VGA master. The Design-Under-Test (DUT) was written by Verilog HDL and tested on the Nexys 4 FPGA, and the verification environment can be automatically run on ModelSim Simulator. 