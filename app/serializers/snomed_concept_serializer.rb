class SnomedConceptSerializer < ActiveModel::Serializer
  attributes :id, :label, :concept_id, :term, :fsn

  def label
    object.term
  end
end
