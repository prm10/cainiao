function score=calculate_score_seperate(prediction,reality,config_a,config_b)
%{
prediction: 1000*6
reality:    1000*6
config_*:    1000*6
%}
cost_less=max(reality-prediction,zeros(size(prediction)));
cost_more=max(prediction-reality,zeros(size(prediction)));
score=config_a.*cost_less+config_b.*cost_more;

