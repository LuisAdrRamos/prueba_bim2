import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/pet_entity.dart';
import '../bloc/pet_bloc.dart';
import '../bloc/pet_event.dart';
import '../bloc/pet_state.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';
import '../../../auth/presentation/widgets/loading_overlay.dart';

class CreatePetPage extends StatefulWidget {
  final PetEntity?
      petToEdit; // Si es null, es CREAR. Si tiene datos, es EDITAR.

  const CreatePetPage({super.key, this.petToEdit});

  @override
  State<CreatePetPage> createState() => _CreatePetPageState();
}

class _CreatePetPageState extends State<CreatePetPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _ageController;
  late TextEditingController _descriptionController;

  late String _selectedSpecies;
  late String _selectedGender;
  late String _selectedSize;

  File? _imageFile; // Foto nueva seleccionada
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Inicializar datos (Pre-llenar si es edición)
    final pet = widget.petToEdit;
    _nameController = TextEditingController(text: pet?.name ?? '');
    _breedController = TextEditingController(text: pet?.breed ?? '');
    _ageController = TextEditingController(text: pet?.age ?? '');
    _descriptionController =
        TextEditingController(text: pet?.description ?? '');

    _selectedSpecies = pet?.species ?? 'Perro';
    _selectedGender = pet?.gender ?? 'Macho';
    _selectedSize = pet?.size ?? 'Mediano';
  }

  // ... (Función _showImageSourceActionSheet y _pickImage IGUALES QUE ANTES) ...
  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext _) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Cámara'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile =
          await _picker.pickImage(source: source, imageQuality: 50);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      // Manejar error
    }
  }

  void _submit(BuildContext context) {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      // Validación de imagen: Debe tener foto nueva O estar editando una existente
      if (_imageFile == null && widget.petToEdit == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes seleccionar una foto')),
        );
        return;
      }

      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        // MODO EDICIÓN
        if (widget.petToEdit != null) {
          final updatedPet = PetEntity(
            id: widget.petToEdit!.id, // Mismo ID
            name: _nameController.text,
            species: _selectedSpecies,
            breed: _breedController.text,
            age: _ageController.text,
            size: _selectedSize,
            gender: _selectedGender,
            description: _descriptionController.text,
            imageUrl: widget.petToEdit!
                .imageUrl, // Se mantiene URL vieja hasta que el server la cambie
            locationLat: widget.petToEdit!.locationLat,
            locationLng: widget.petToEdit!.locationLng,
            shelterId: widget.petToEdit!.shelterId,
            isAdopted: widget.petToEdit!.isAdopted,
          );

          context
              .read<PetBloc>()
              .add(UpdatePet(pet: updatedPet, newImage: _imageFile));
        }
        // MODO CREACIÓN
        else {
          final newPet = PetEntity(
            id: const Uuid().v4(),
            name: _nameController.text,
            species: _selectedSpecies,
            breed: _breedController.text,
            age: _ageController.text,
            size: _selectedSize,
            gender: _selectedGender,
            description: _descriptionController.text,
            imageUrl: '',
            locationLat: 0.0,
            locationLng: 0.0,
            shelterId: authState.user.id,
            isAdopted: false,
          );
          context
              .read<PetBloc>()
              .add(CreatePet(pet: newPet, imageFile: _imageFile!));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.petToEdit != null;

    return BlocProvider(
      create: (_) => getIt<PetBloc>(),
      child: BlocConsumer<PetBloc, PetState>(
        listener: (context, state) {
          if (state is PetOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.green),
            );
            Navigator.pop(context); // Volver
          } else if (state is PetError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (builderContext, state) {
          return LoadingOverlay(
            isLoading: state is PetLoading,
            child: Scaffold(
              appBar: AppBar(
                  title: Text(isEditing ? 'Editar Mascota' : 'Nueva Mascota')),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ÁREA DE FOTO
                      GestureDetector(
                        onTap: () => _showImageSourceActionSheet(context),
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                            // Lógica de visualización de imagen
                            image: _imageFile != null
                                ? DecorationImage(
                                    image: FileImage(_imageFile!),
                                    fit: BoxFit.cover)
                                : (isEditing &&
                                        widget.petToEdit!.imageUrl.isNotEmpty)
                                    ? DecorationImage(
                                        image: NetworkImage(
                                            widget.petToEdit!.imageUrl),
                                        fit: BoxFit.cover)
                                    : null,
                          ),
                          child: (_imageFile == null && !isEditing)
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.camera_alt,
                                        size: 50, color: Colors.grey),
                                    Text('Toca para agregar foto')
                                  ],
                                )
                              : null,
                        ),
                      ),
                      if (isEditing)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Toca la imagen para cambiarla',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey)),
                        ),
                      const SizedBox(height: 20),

                      // CAMPOS (Mismos que antes)
                      CustomTextField(
                          controller: _nameController,
                          label: 'Nombre',
                          hint: 'Ej: Firulais',
                          prefixIcon: Icons.pets),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedSpecies,
                        decoration: const InputDecoration(
                            labelText: 'Especie', border: OutlineInputBorder()),
                        items: ['Perro', 'Gato']
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedSpecies = v!),
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                          controller: _breedController,
                          label: 'Raza',
                          hint: 'Ej: Labrador',
                          prefixIcon: Icons.category),
                      const SizedBox(height: 10),
                      CustomTextField(
                          controller: _ageController,
                          label: 'Edad',
                          hint: 'Ej: 2 años',
                          prefixIcon: Icons.cake),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: const InputDecoration(
                                  labelText: 'Sexo',
                                  border: OutlineInputBorder()),
                              items: ['Macho', 'Hembra']
                                  .map((e) => DropdownMenuItem(
                                      value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedGender = v!),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedSize,
                              decoration: const InputDecoration(
                                  labelText: 'Tamaño',
                                  border: OutlineInputBorder()),
                              items: ['Pequeño', 'Mediano', 'Grande']
                                  .map((e) => DropdownMenuItem(
                                      value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedSize = v!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                          controller: _descriptionController,
                          label: 'Descripción',
                          hint: 'Historia...',
                          prefixIcon: Icons.description),
                      const SizedBox(height: 30),

                      ElevatedButton(
                        onPressed: state is PetLoading
                            ? null
                            : () => _submit(builderContext),
                        child: Text(
                            isEditing ? 'Guardar Cambios' : 'Publicar Mascota'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
