import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';


class NewUserPage extends StatelessWidget {
  NewUserPage({super.key});

  final nombreController = TextEditingController();
  final albumController = TextEditingController();
  final anioController = TextEditingController();
  final votoController = TextEditingController();
  final almacenamiento = FirebaseStorage.instance;
  final instance = FirebaseFirestore.instance;
  
  Future<String> subirFoto(String path) async {
    // Referencia a la instancia de Firebase Storage
    final storageRef = FirebaseStorage.instance.ref();
    final imagen = File(path); // el archivo que voy a subir
    final random = Random();
  final nombreImagen = nombreController.text + '${random.nextInt(1000000)}.jpg';
    //la referencia donde voy a guardar
    final referenciaFotoPerfil =
        storageRef.child("bandas/imagenAlbum/$nombreImagen");
    final uploadTask = await referenciaFotoPerfil.putFile(imagen);
    final url = await uploadTask.ref.getDownloadURL();
  
    return url;

  

  }




  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as String?;
    if (args != null) {
      instance.collection('bandas').doc(args).get().then((value) {
        nombreController.text = value['Nombre de la banda'];
        albumController.text = value['Nombre del album'];
        anioController.text = value['Año del lanzamiento'].toString();
        votoController.text = value['Votos'].toString();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('agregar banda nueva'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nombre de la banda',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: albumController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Album de la banda',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: anioController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Año de lanzamiento',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: votoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Votos',
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  final data = {     
                    'Nombre de la banda': nombreController.text,
                    'Nombre del album': albumController.text,
                    'Año de lanzamiento': int.parse(anioController.text),
                    'Votos': int.parse(votoController.text),
                      
                  };
                    final respuesta =  await instance.collection('bandas').add(data);
                  print(respuesta);
                  Navigator.pushNamed(context, '/home');
                },
                child: const Text('Agregar'),
                
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();

                    final XFile? image =
                        await picker.pickImage(source: ImageSource.gallery);

                    if (image == null) {
      // Si no se seleccionó ninguna imagen, subir una imagen predeterminada
      final url = await subirFoto('assets/images/goku.jpg');
      print(url);
      return;
    }
                    final url = await subirFoto(image.path);

                    print(url);
                    // image.path
                  },
                  child: const Text('Subir foto')),
            ],
          ),
        ),
      ),
    );
  }

      



}
