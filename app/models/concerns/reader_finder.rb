module ReaderFinder
  def below_average(age)
      where('age < ?', age)
  end
end