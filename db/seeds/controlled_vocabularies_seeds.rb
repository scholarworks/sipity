$stdout.puts 'Creating controlled vocabularies'
[
  ['copyright', 'Attribution 3.0 United States', 'http://creativecommons.org/licenses/by/3.0/us/'],
  ['copyright', 'Attribution-ShareAlike 3.0 United States', 'http://creativecommons.org/licenses/by-sa/3.0/us/'],
  ['copyright', 'Attribution-NonCommercial 3.0 United States', 'http://creativecommons.org/licenses/by-nc/3.0/us/'],
  ['copyright', 'Attribution-NoDerivs 3.0 United States', 'http://creativecommons.org/licenses/by-nd/3.0/us/'],
  ['copyright', 'Attribution-NonCommercial-NoDerivs 3.0 United States', 'http://creativecommons.org/licenses/by-nc-nd/3.0/us/'],
  ['copyright', 'Attribution-NonCommercial-ShareAlike 3.0 United States', 'http://creativecommons.org/licenses/by-nc-sa/3.0/us/'],
  ['copyright', 'Public Domain Mark 1.0', 'http://creativecommons.org/publicdomain/mark/1.0/'],
  ['copyright', 'CC0 1.0 Universal', 'http://creativecommons.org/publicdomain/zero/1.0/'],
  ['copyright', 'All rights reserved', 'All rights reserved'],
  ['resource_consulted', 'Print sources', 'Print sources'],
  ['resource_consulted', 'Electronic journals', 'Electronic journals'],
  ['resource_consulted', 'Databases accessed via Hesburgh Libraries', 'Databases accessed via Hesburgh Libraries'],
  ['resource_consulted', 'Web sites or other internet research sources', 'Web sites or other internet research sources'],
  ['resource_consulted', 'Hesburgh Libraries Rare Books and Special Collections and/or Archives', 'Hesburgh Libraries Rare Books and Special Collections and/or Archives'],
  ['resource_consulted', 'Consultation with a librarian', 'Consultation with a librarian'],
  ['citation_style', 'American Psychological Association', 'APA'],
  ['citation_style', 'Chicago Manual of Style', 'Chicago'],
  ['citation_style', 'Modern Language Association', 'MLA'],
  ['award_category', 'Senior/Honors Thesis'],
  ['award_category', '2000–4000 Level Papers'],
  ['award_category', '10000 Level Papers'],
  ['work_patent_strategy', 'already_patented'],
  ['work_patent_strategy', 'will_not_patent'],
  ['work_patent_strategy', 'going_to_patent'],
  ['work_patent_strategy', 'do_not_know']
].each do |predicate_name, term_label, term_uri|
  Sipity::Models::SimpleControlledVocabulary.find_or_create_by!(
  predicate_name: predicate_name, term_label: term_label, term_uri: term_uri)
end

$stdout.puts 'Creating degree names...'
[
  ['degree', 'Doctor of Musical Arts', 'DMA'],
  ['degree', 'Doctor of Philosophy', 'PhD'],
  ['degree', 'Master of Arts', 'MA'],
  ['degree', 'Master of Fine Arts', 'MFA'],
  ['degree', 'Master of Medieval Studies', 'MMS'],
  ['degree', 'Master of Science', 'MS'],
  ['degree', 'Master of Science in Aerospace Engineering', 'MSAE'],
  ['degree', 'Master of Science in Bioengineering', 'MSBioE'],
  ['degree', 'Master of Science in Chemical Engineering', 'MSChE'],
  ['degree', 'Master of Science in Civil Engineering', 'MSCE'],
  ['degree', 'Master of Science in Computer Science and Engineering', 'MSCSE'],
  ['degree', 'Master of Science in Earth Sciences', 'MSES'],
  ['degree', 'Master of Science in Electrical Engineering', 'MSEE'],
  ['degree', 'Master of Science in Environmental Engineering', 'MSEnvE'],
  ['degree', 'Master of Science in Geological Sciences', 'MSGS'],
  ['degree', 'Master of Science in Interdisciplinary Mathematics', 'MSIM'],
  ['degree', 'Master of Science in Mechanical Engineering', 'MSME'],
  ['program_name', 'Aerospace and Mechanical Engineering', 'AME'],
  ['program_name', 'Anthropology', 'ANTH'],
  ['program_name', 'Applied and Computational Mathematics and Statistics', 'ACMS'],
  ['program_name', 'Art, Art History, and Design', 'ART'],
  ['program_name', 'Bioengineering', 'BIOE'],
  ['program_name', 'Biological Sciences', 'BIOS'],
  ['program_name', 'Chemical and Biomolecular Engineering', 'CBE, CHEG'],
  ['program_name', 'Civil and Environmental Engineering and Earth Sciences', 'Civil Engineering and Geological Sciences, CEEES, CEGS'],
  ['program_name', 'Chemistry', 'CHEM'],
  ['program_name', 'Classics', 'CLAS'],
  ['program_name', 'Computer Science and Engineering', 'CSE'],
  ['program_name', 'Creative Writing', 'CW, ENGL-CW'],
  ['program_name', 'Economics', 'Economics and Econometrics, ECON'],
  ['program_name', 'Early Christian Studies', 'ECS'],
  ['program_name', 'Electrical Engineering', 'EE'],
  ['program_name', 'English', 'ENGL'],
  ['program_name', 'History', 'HIST'],
  ['program_name', 'History and Philosophy of Science', 'HPS'],
  ['program_name', 'Integrated Biomedical Sciences', 'IBMS'],
  ['program_name', 'Peace Studies', 'PEACE, IIPS'],
  ['program_name', 'Law', nil],
  ['program_name', 'Literature', 'PhD in Literature, LIT'],
  ['program_name', 'Mathematics', 'MATH'],
  ['program_name', 'Medieval Studies', 'Medieval Institute, MI, MS'],
  ['program_name', 'Philosophy', 'PHIL'],
  ['program_name', 'Physics', 'PHYS'],
  ['program_name', 'Political Science', 'POLS'],
  ['program_name', 'Psychology', 'PSY'],
  ['program_name', 'Romance Languages and Literatures', 'ROML'],
  ['program_name', 'Sacred Music', 'SACM'],
  ['program_name', 'Sociology', 'SOC'],
  ['program_name', 'Theology', 'THEO']
].each do |predicate_name, term_label, subject_searchable_terms|
    # NOTICE: Swallowing the subject search terms and nullifying term_uri
  if vocab = Sipity::Models::SimpleControlledVocabulary.find_by(predicate_name: predicate_name, term_label: term_label)
    if vocab.term_uri !~ %r{\A\w+://\w}
      vocab.update(term_uri: nil)
    end
  else
    Sipity::Models::SimpleControlledVocabulary.create!(predicate_name: predicate_name, term_label: term_label)
  end
end
