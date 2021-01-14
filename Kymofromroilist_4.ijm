//generate and save kymographs from rois, save rois in the process. v0.4 by Andre Voelzmann
//needs KymoResliceWide plugin/macro

macro "kymos from rois [q]" {
if (nImages==0) {exit("There are no open images - open timeseries, mark roi and retry");} // catch error when there is no open image
else {
imageTitle=getTitle();
dir = getDirectory("image"); 				// get image directory for saving files
Dialog.create("Kymograph Stretch option"); 	// dialog to get desired parameters for kymograph generation and image stretching
Dialog.addChoice("Save rois?:", newArray("yes", "no"), "yes");
Dialog.addChoice("Kymograph mode:", newArray("Maximum", "Average"), "Maximum");
Dialog.addNumber("set kymograph stretch factor in x", 1);
Dialog.addNumber("set kymograph stretch factor in y", 2);
Dialog.addChoice("interpolation type:", newArray("None", "Bilinear", "Bicubic"), "Bicubic");
Dialog.show();
srois_ = Dialog.getChoice(); 			// save rois
avmax_ = Dialog.getChoice(); 			// average or maximum for kymograph
ksfx_=Dialog.getNumber;					// stretch factor x-direction
ksfy_=Dialog.getNumber;					// stretch factor y-direction
n = roiManager("count");				// number of rois, determines how many kymographs to generate
interpolation_ = Dialog.getChoice();	// type of interpolation for the image transformation (stretching)

if (n>0) {
 	
	for (i=0; i<n; i++) {				// go through list of rois in roiManager, generate kymograph for each of them
		selectWindow(imageTitle);
		roiManager("Select", i);
		run("KymoResliceWide ", "intensity=&avmax_ ignore");	// use KymoResliceWide plugin - this needs to be present. Error when missing is not caught yet
		run("Size...", "width="+( getWidth() * ksfx_ )+" height="+( getHeight() * ksfy_ )+" average interpolation=&interpolation_");	// transform image according to given parameters
		saveAs("tiff", dir+imageTitle+"_"+i+"_stretchedby_"+ksfx_+"x"+ksfy_+"-"+interpolation_+".tif");		// save kymograph image
		close();						// close the kymograph file
		}
	if (srois_=="yes") {				// save rois as files in the same directory if this option has been chosen
		selectWindow("ROI Manager");
		roiManager("Deselect"); 
			if (n>1) {
				roiManager("Save", dir+imageTitle+".zip");}
			else if (n==1) {roiManager("Save", dir+imageTitle+".roi");}	// single roi file is saved as .roi as per ImageJ standard
			else {exit("can't find roi");} 	// very unlikely event
			selectWindow("ROI Manager");
			run("Close");						// close roiManager
	}
	else {selectWindow("ROI Manager");
		run("Close");}						// close roiManager
		selectWindow(imageTitle); 			// select and close original imagefile
		run("Close");	
		//		run("Close All");	// close all open images - user might not like this if they have several images open...
}
else {exit("No roi in roiManager - kymographs not saved, file kept open - add roi and retry");}
}
run("Collect Garbage");
exit("Macro is done");}
