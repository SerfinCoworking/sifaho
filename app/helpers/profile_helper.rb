module ProfileHelper
  def patient_avatar(patient, first_size=162, second_size=200 )
    if patient.avatar.attached?
      main_app.url_for(patient.avatar.variant(resize: "#{first_size}x#{second_size}^", gravity: "center", crop: "#{first_size}x#{second_size}+0+0"))
    else
      image_path('profile-placeholder.jpg')
    end
  end

  def professional_avatar(professional, size=40)
    if professional.avatar.attached?
      main_app.url_for(professional.avatar.variant(resize: "#{size}x#{size}^", gravity: "center",crop: "#{size}x#{size}+0+0"))
    else
      image_path('profile-placeholder.jpg')
    end
  end

  def user_avatar(user, size=40)
    if user.profile.avatar.attached?
      main_app.url_for(user.profile.avatar.variant(resize: "#{size}x#{size}^", gravity: "center",crop: "#{size}x#{size}+0+0"))
    else
      image_path('profile-placeholder.jpg')
    end
  end
end