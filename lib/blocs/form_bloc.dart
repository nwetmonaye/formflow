import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formflow/models/form_model.dart';
import 'package:formflow/repositories/form_repository.dart';

// Events
abstract class FormEvent extends Equatable {
  const FormEvent();

  @override
  List<Object?> get props => [];
}

class LoadForms extends FormEvent {
  final String userId;

  const LoadForms(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CreateForm extends FormEvent {
  final FormModel form;

  const CreateForm(this.form);

  @override
  List<Object?> get props => [form];
}

class UpdateForm extends FormEvent {
  final String formId;
  final FormModel form;

  const UpdateForm(this.formId, this.form);

  @override
  List<Object?> get props => [formId, form];
}

class DeleteForm extends FormEvent {
  final String formId;

  const DeleteForm(this.formId);

  @override
  List<Object?> get props => [formId];
}

// States
abstract class FormState extends Equatable {
  const FormState();

  @override
  List<Object?> get props => [];
}

class FormInitial extends FormState {}

class FormLoading extends FormState {}

class FormsLoaded extends FormState {
  final List<FormModel> forms;

  const FormsLoaded(this.forms);

  @override
  List<Object?> get props => [forms];
}

class FormCreated extends FormState {
  final String formId;

  const FormCreated(this.formId);

  @override
  List<Object?> get props => [formId];
}

class FormUpdated extends FormState {
  final String formId;

  const FormUpdated(this.formId);

  @override
  List<Object?> get props => [formId];
}

class FormDeleted extends FormState {
  final String formId;

  const FormDeleted(this.formId);

  @override
  List<Object?> get props => [formId];
}

class FormError extends FormState {
  final String message;

  const FormError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class FormBloc extends Bloc<FormEvent, FormState> {
  final FormRepository _formRepository;

  FormBloc(this._formRepository) : super(FormInitial()) {
    on<LoadForms>(_onLoadForms);
    on<CreateForm>(_onCreateForm);
    on<UpdateForm>(_onUpdateForm);
    on<DeleteForm>(_onDeleteForm);
  }

  Future<void> _onLoadForms(LoadForms event, Emitter<FormState> emit) async {
    emit(FormLoading());
    try {
      final forms = await _formRepository.getUserForms(event.userId);
      emit(FormsLoaded(forms));
    } catch (e) {
      emit(FormError(e.toString()));
    }
  }

  Future<void> _onCreateForm(CreateForm event, Emitter<FormState> emit) async {
    emit(FormLoading());
    try {
      final formId = await _formRepository.createForm(event.form);
      emit(FormCreated(formId));
      // Reload forms after creation
      final forms = await _formRepository.getUserForms(event.form.createdBy);
      emit(FormsLoaded(forms));
    } catch (e) {
      emit(FormError(e.toString()));
    }
  }

  Future<void> _onUpdateForm(UpdateForm event, Emitter<FormState> emit) async {
    emit(FormLoading());
    try {
      await _formRepository.updateForm(event.formId, event.form);
      emit(FormUpdated(event.formId));
      // Reload forms after update
      final forms = await _formRepository.getUserForms(event.form.createdBy);
      emit(FormsLoaded(forms));
    } catch (e) {
      emit(FormError(e.toString()));
    }
  }

  Future<void> _onDeleteForm(DeleteForm event, Emitter<FormState> emit) async {
    emit(FormLoading());
    try {
      await _formRepository.deleteForm(event.formId);
      emit(FormDeleted(event.formId));
    } catch (e) {
      emit(FormError(e.toString()));
    }
  }
}
