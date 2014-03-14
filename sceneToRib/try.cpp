#include <iostream>
#include <fstream>
#include <sstream>

using namespace std;

void convertToRib(string line){
    string command;
    istringstream iss(line);
	iss >> command;
	if (command == "sphere" ||
		command == "cone" ||
		command == "cylinder"){
		int red, blue, green;
		float transparency, reflection;
		float kd1, ks1;
		string surface;
		//surface_t st;
		float transformMatrix[4][4];
		
		iss >> red >> green >> blue;
		iss >> transparency >> reflection;

		iss >> kd1 >> ks1;

		iss >> surface;

		//st = DIFFUSE;

		//if (surface == "specular") st = SPECULAR;
		//if (surface == "diffuse") st = DIFFUSE;

  		for (int i = 0; i < 3; ++i) {
			for (int j = 0; j < 4; ++j) {
				iss >> transformMatrix[i][j];
			}
			transformMatrix[3][i] = 0;
		}
		transformMatrix[3][3] = 1;
		
		/*
		TransformBegin
			Rotate 0 0 0 1
			Translate 5 0 0
			Sphere 1 -1 1 360
		TransformEnd
		*/

        std::ofstream ofs;
  		ofs.open ("test.txt", std::ofstream::out | std::ofstream::app);
  		ofs << "AttributeBegin\n";
  		ofs << "\t" << "Color [" << red/255.0 << " " << green/255.0 << " " << blue/255.0 << "]\n";
  		ofs << "\t" << "TransformBegin\n";
  		ofs << "\t" << "\t" << "Transform [ ";

		for (int i = 0; i < 4; ++i) {
			for (int j = 0; j < 4; ++j) {
				ofs << transformMatrix[i][j] << " ";
			}
			//transformMatrix[3][i] = 0;
		}
		ofs << "]\n";
		

		if (command == "sphere") {
			ofs << "\t" << "\t" << "Sphere 1 -1 1 360\n";
		}
		else if (command == "cone") {
			ofs << "\t" << "\t" << "Cone 1 1 360\n";
		}
		else if (command == "cylinder") {
			ofs << "\t" << "\t" << "Cylinder 1 -1 1 360\n";
		}
		ofs << "\t" << "TransformEnd\n";
		ofs << "AttributeEnd\n\n";
	}
	else if (command == "samples") { 
		int samples;
		iss >> samples; 
	}
	else if (command == "bounces") { 
		int bounces;
		iss >> bounces; 
	}
	else if (command == "camera") {
		float camX, camY, camZ;
		iss >> camX >> camY >> camZ;
	}
	else if (command == "light") {
		float x, y, z;
		iss >> x >> y >> z;

		float intensity;
		iss >> intensity;

		float cr, cg, cb;
		iss >> cr >> cg >> cb;

		// cout << light->intensity << " " << light->cr << endl;
	}
}

int main(){
    std::ofstream ofs;
  	ofs.open ("test.txt", std::ofstream::out);
  	ofs << "";
	string line;
	ifstream myfile ("a");
	if (myfile.is_open()){
		while ( getline (myfile,line) ){
			convertToRib(line);
			cout<<line<<endl;
		}
		myfile.close();
	}
}

