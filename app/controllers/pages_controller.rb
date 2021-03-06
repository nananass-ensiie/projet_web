class PagesController < ApplicationController
  def home
  end

  def inscription
  end

  def admin
    @teacher_attente = Teacher.where(role: "attente")
  end

  def prof
    @prof = set_current_teacher
    @matiere = Subject.where(teacher_id: @prof.id)
  end

  def ajoutmatiere
    @prof = set_current_teacher
  end

  def examprof
    @prof = set_current_teacher
    @matiere = set_current_subject
    @epreuve = Exam.where(subject_id: @matiere.id)
  end

  def ajoutexam
    @prof = set_current_teacher
    @matiere = set_current_subject
  end

  def note
    @prof = set_current_teacher
    @matiere = set_current_subject
    @epreuve = set_current_exam
    @mark = Mark.where(exam_id: @epreuve.id)
  end

  def eleve
    @eleve = set_current_studient
    @mark = Mark.where(studient_id: @eleve.id)
  end

  def inviteleve

  end

  def connexion
    if (params[:nom] != '') && (params[:email] != '') && (params[:password] != '')
      @admin = Administrateur.where(nom: params[:nom], email: params[:email], password: params[:password]).first
      @prof = Teacher.where(surname: params[:nom], email: params[:email], password: params[:password], role: "accepte").first
      @eleve = Studient.where(surname: params[:nom], email: params[:email], password: params[:password]).first
      if @admin
        redirect_to '/pages/admin'
      else
        if @prof
          session[:id_teacher]=@prof.id
          redirect_to '/pages/prof'
        else
          if @eleve
            session[:id_studient]=@eleve.id
            redirect_to '/pages/eleve'
          else
            flash[:error] = "Vous n'êtes pas inscrit ou l'administrateur n'a pas accepté votre compte."
            redirect_to '/pages/home'
          end
        end
      end
    else
      flash[:error] = "incorrect"
      redirect_to '/pages/home'
    end
  end

  def inscrire
    if (params[:nom] != '') && (params[:email] != '') && (params[:password] != '') && (params[:prenom] != '')
      @eleve = Studient.all
      compteur = 0
      @eleve.each do |mail|
        if params[:email] == mail.email
          compteur += 1
        end
      end
      if compteur == 0
        @prof = Teacher.all
        plus = 0
        @prof.each do |mailp|
          if params[:email] == mailp.email
            plus += 1
          end
        end
        if plus == 0
          Teacher.create(surname: params[:nom], name: params[:prenom], email: params[:email], password: params[:password], role: "attente")
          flash[:info] = "Votre demande a bien été prise en compte"
          redirect_to '/pages/home'
        else
          flash[:info] = "Vous vous êtes déjà inscrit. Si vous n'arrivez pas à vous connecter attendez la confirmation de votre inscription par l'administrateur."
          redirect_to '/pages/inscription'
        end
      else
        flash[:info] = "Les étudiants n'ont pas le droit de s'inscrire"
        redirect_to '/pages/home'
      end
    else
      flash[:info] = "incorrect"
      redirect_to '/pages/inscription'
    end
  end

  def accepter
    Teacher.find(params[:id]).update(role: "accepte")
    redirect_to '/pages/admin'
  end

  def refuser
    Teacher.find(params[:id]).destroy
    redirect_to '/pages/admin'
  end

  def suppnote
    Mark.find(params[:note]).destroy
    redirect_to '/pages/note'
  end

  def suppepp
    @ep = Exam.find(params[:ep])
    @note = Mark.where(exam_id: @ep.id)
    @note.each do |sup|
      Mark.find(sup.id).destroy
    end
    Exam.find(params[:ep]).destroy
    redirect_to '/pages/examprof'
  end

  def suppmat
    @mat = Subject.find(params[:mat])
    @ep = Exam.where(subject_id: @mat.id)
    @ep.each do |supep|
      @note = Mark.where(exam_id: supep.id)
      @note.each do |supnote|
        Mark.find(supnote.id).destroy
      end
      Exam.find(supep.id).destroy
    end
    Subject.find(params[:mat]).destroy
    redirect_to '/pages/prof'
  end

  def set_current_teacher
    if session[:id_teacher]
      @current_teacher = Teacher.find(session[:id_teacher])
    end
  end

  def set_current_studient
    if session[:id_studient]
      @current_studient = Studient.find(session[:id_studient])
    end
  end

  def ajouter
    if (params[:matiere] != '') && (params[:debut] != '') && (params[:fin] != '')
      Subject.create(title: params[:matiere], begin: params[:debut], end: params[:fin], teacher_id: params[:id])
      redirect_to '/pages/prof'
    else
      redirect_to '/pages/prof'
    end
  end

  def examen
    @matiere = Subject.where(id: params[:id_mat]).first
    session[:id_subject]=@matiere.id
    redirect_to '/pages/examprof'
  end

  def set_current_subject
    if session[:id_subject]
      @current_subject = Subject.find(session[:id_subject])
    end
  end

  def ajouterexam
    if (params[:epreuve] != '') && (params[:date] != '')
      Exam.create(title: params[:epreuve], date: params[:date], subject_id: params[:matiere])
      redirect_to '/pages/examprof'
    else
      redirect_to '/pages/examprof'
    end
  end

  def voirnote
    @epreuve = Exam.where(id: params[:id_epreuve]).first
    session[:id_exam]=@epreuve.id
    redirect_to '/pages/note'
  end

  def set_current_exam
    if session[:id_exam]
      @current_exam = Exam.find(session[:id_exam])
    end
  end

  def ajoutnote
    if ((params[:nom] != '') && (params[:prenom] != '') && (params[:note] != '')) then
      @eleve = Studient.where(surname: params[:nom], name: params[:prenom]).first
      if @eleve then
        @note = Mark.where(exam_id: params[:exam])
        compteur = 0
        @note.each do |note_eleve|
          if note_eleve.studient_id == @eleve.id
            compteur +=1
          end
        end
        if compteur == 0
          Mark.create(mark: params[:note], exam_id: params[:exam], studient_id: @eleve.id, teacher_id: params[:prof])
        else
          flash[:info] = "L'élève a déjà une note pour cet examen."
        end
        redirect_to '/pages/note'
      else
        redirect_to '/pages/note'
        flash[:info] = "Cet élève n'existe pas"
      end
    else
      redirect_to '/pages/note'
      flash[:info] = "Remplissez les champs svp"
    end
  end

  def inviter
    if (params[:nom] != '') && (params[:email] != '') && (params[:prenom] != '')
      @eleve = Studient.all
      compteur = 0
      @eleve.each do |el|
        if el.email == params[:email]
          compteur += 1
        end
      end
      if compteur == 0
        password = ""
        8.times{password  << ((rand(2)==1?65:97) + rand(25)).chr}
        @nveleve = Studient.create(surname: params[:nom], name: params[:prenom], email: params[:email], password: password)
        UsermailerMailer.sample_email(@nveleve).deliver
        redirect_to '/pages/inviteleve'
        flash[:info] = "L'invitation a bien été envoyé"
      else
        redirect_to '/pages/inviteleve'
        flash[:info] = "Cet élève a déjà été invité"
      end
    end


  end

end
