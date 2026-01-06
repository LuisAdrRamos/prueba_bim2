// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:get_it/get_it.dart' as _i174;
import 'package:http/http.dart' as _i519;
import 'package:injectable/injectable.dart' as _i526;
import 'package:prueba_bim2/core/network/network_info.dart' as _i949;
import 'package:prueba_bim2/features/adoption_management/data/datasources/adoption_remote_data_source.dart'
    as _i70;
import 'package:prueba_bim2/features/adoption_management/data/repositories/adoption_repository_impl.dart'
    as _i319;
import 'package:prueba_bim2/features/adoption_management/domain/repositories/adoption_repository.dart'
    as _i312;
import 'package:prueba_bim2/features/adoption_management/presentation/bloc/adoption_bloc.dart'
    as _i888;
import 'package:prueba_bim2/features/ai_assistant/data/datasources/ai_remote_data_source.dart'
    as _i703;
import 'package:prueba_bim2/features/ai_assistant/data/repositories/ai_repository_impl.dart'
    as _i95;
import 'package:prueba_bim2/features/ai_assistant/domain/repositories/ai_repository.dart'
    as _i115;
import 'package:prueba_bim2/features/ai_assistant/presentation/bloc/chat_bloc.dart'
    as _i909;
import 'package:prueba_bim2/features/auth/data/datasources/auth_remote_data_source.dart'
    as _i714;
import 'package:prueba_bim2/features/auth/data/repositories/auth_repository_impl.dart'
    as _i1008;
import 'package:prueba_bim2/features/auth/domain/repositories/auth_repository.dart'
    as _i169;
import 'package:prueba_bim2/features/auth/domain/usecases/get_current_user.dart'
    as _i587;
import 'package:prueba_bim2/features/auth/domain/usecases/reset_password.dart'
    as _i796;
import 'package:prueba_bim2/features/auth/domain/usecases/sign_in.dart' as _i74;
import 'package:prueba_bim2/features/auth/domain/usecases/sign_out.dart'
    as _i926;
import 'package:prueba_bim2/features/auth/domain/usecases/sign_up.dart'
    as _i695;
import 'package:prueba_bim2/features/auth/domain/usecases/update_profile.dart'
    as _i801;
import 'package:prueba_bim2/features/auth/presentation/bloc/auth_bloc.dart'
    as _i916;
import 'package:prueba_bim2/features/pet_management/data/datasources/pet_remote_data_source.dart'
    as _i236;
import 'package:prueba_bim2/features/pet_management/data/repositories/pet_repository_impl.dart'
    as _i1036;
import 'package:prueba_bim2/features/pet_management/domain/repositories/pet_repository.dart'
    as _i1019;
import 'package:prueba_bim2/features/pet_management/presentation/bloc/pet_bloc.dart'
    as _i262;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i949.NetworkInfo>(
        () => _i949.NetworkInfoImpl(gh<_i895.Connectivity>()));
    gh.lazySingleton<_i70.AdoptionRemoteDataSource>(
        () => _i70.AdoptionRemoteDataSourceImpl(gh<_i454.SupabaseClient>()));
    gh.lazySingleton<_i714.AuthRemoteDataSource>(
        () => _i714.AuthRemoteDataSourceImpl(gh<_i454.SupabaseClient>()));
    gh.lazySingleton<_i236.PetRemoteDataSource>(
        () => _i236.PetRemoteDataSourceImpl(gh<_i454.SupabaseClient>()));
    gh.lazySingleton<_i1019.PetRepository>(() => _i1036.PetRepositoryImpl(
          remoteDataSource: gh<_i236.PetRemoteDataSource>(),
          networkInfo: gh<_i949.NetworkInfo>(),
        ));
    gh.factory<_i262.PetBloc>(() => _i262.PetBloc(gh<_i1019.PetRepository>()));
    gh.lazySingleton<_i703.AIRemoteDataSource>(
        () => _i703.AIRemoteDataSourceImpl(gh<_i519.Client>()));
    gh.lazySingleton<_i169.AuthRepository>(() => _i1008.AuthRepositoryImpl(
          remoteDataSource: gh<_i714.AuthRemoteDataSource>(),
          networkInfo: gh<_i949.NetworkInfo>(),
        ));
    gh.lazySingleton<_i312.AdoptionRepository>(() =>
        _i319.AdoptionRepositoryImpl(gh<_i70.AdoptionRemoteDataSource>()));
    gh.factory<_i587.GetCurrentUser>(
        () => _i587.GetCurrentUser(gh<_i169.AuthRepository>()));
    gh.factory<_i796.ResetPassword>(
        () => _i796.ResetPassword(gh<_i169.AuthRepository>()));
    gh.factory<_i74.SignIn>(() => _i74.SignIn(gh<_i169.AuthRepository>()));
    gh.factory<_i926.SignOut>(() => _i926.SignOut(gh<_i169.AuthRepository>()));
    gh.factory<_i695.SignUp>(() => _i695.SignUp(gh<_i169.AuthRepository>()));
    gh.factory<_i801.UpdateProfile>(
        () => _i801.UpdateProfile(gh<_i169.AuthRepository>()));
    gh.lazySingleton<_i115.AIRepository>(
        () => _i95.AIRepositoryImpl(gh<_i703.AIRemoteDataSource>()));
    gh.factory<_i916.AuthBloc>(() => _i916.AuthBloc(
          signIn: gh<_i74.SignIn>(),
          signUp: gh<_i695.SignUp>(),
          resetPassword: gh<_i796.ResetPassword>(),
          signOut: gh<_i926.SignOut>(),
          getCurrentUser: gh<_i587.GetCurrentUser>(),
          updateProfile: gh<_i801.UpdateProfile>(),
        ));
    gh.factory<_i888.AdoptionBloc>(
        () => _i888.AdoptionBloc(gh<_i312.AdoptionRepository>()));
    gh.factory<_i909.ChatBloc>(() => _i909.ChatBloc(gh<_i115.AIRepository>()));
    return this;
  }
}
